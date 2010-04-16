#
# test/unit/yast/service_resource_test.rb
#
require File.join(File.dirname(__FILE__), '..', '..', 'test_helper')
require File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'yast', 'service_resource')

class Item < ActiveResource::Base
  self.site = "http:://localhost:8080"  
end


class YaSTServiceResourceBaseTest < ActiveSupport::TestCase
  def setup
    # simulate we are loggedin
    YaST::ServiceResource::Session.site = "http://localhost:8080"
    YaST::ServiceResource::Session.login = "linus"
    YaST::ServiceResource::Session.auth_token = nil
    # first define the resources the server would return
    # we have a resource /foos and a singleton /master
    @resources_response = <<EOF
      <resources type=\"array\">
        <resource>
          <interface>org.yast.foo</interface>
          <policy></policy>
          <singular type="boolean">false</singular>
          <href>/foos</href>
        </resource>
        <resource>
          <interface>org.yast.master</interface>
          <policy>org.opensuse.yast</policy>
          <singular type="boolean">true</singular>
          <href>/master</href>
        </resource>
      </resources>
EOF
    @resources_with_prefix_response = <<EOF
      <resources type=\"array\">
        <resource>
          <interface>org.yast.foo</interface>
          <policy></policy>
          <singular type="boolean">false</singular>
          <href>/someprefix/foos</href>
        </resource>
        <resource>
          <interface>org.yast.master</interface>
          <policy>org.opensuse.yast</policy>
          <singular type="boolean">true</singular>
          <href>/someprefix/master</href>
        </resource>
      </resources>
EOF
    
    @foos_response = <<EOF
      <foos type=\"array\">
        <foo>
          <bar>Hello</bar>
        </foo>
        <foo>
          <bar>Goodbye</bar>
        </foo>
      </foos>
EOF
    
    @foo_response = "<foo><bar>Bye</bar></foo>"
    @master_response = "<master><name>He-Man</name></master>"
    # simulate that we are logged to a service
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_proxy_works
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/resources.xml", {}, @resources_response
      mock.get "/foos.xml", {}, @foos_response
      mock.get "/foos/1.xml", {}, @foo_response
    end
    
    @proxy = YaST::ServiceResource.proxy_for("org.yast.foo")
    assert_equal "YaST::ServiceResource::Proxies::Foo", @proxy.name.to_s
    # the proxy should work returning collections
    c = @proxy.find(:all)
    assert_equal c.class, Array
    assert_equal 2, c.size
    assert_equal "Hello", c.first.bar
  end

  def test_proxy_works_with_singleton
    ActiveResource::HttpMock.respond_to do |mock|
      mock.put "/master.xml", {}, nil, 200
      mock.get "/resources.xml", {}, @resources_response
      mock.get "/master.xml", {}, @master_response
      mock.post "/master.xml", {}, @master_response, 201
      mock.delete "/master.xml", {}, @master_response, 200
    end
    
    @proxy = YaST::ServiceResource.proxy_for("org.yast.master")
    # the proxy is an anonymous class
    assert @proxy.singular?
    c = @proxy.find
    # only one
    assert_not_equal c.class, Array
    assert_equal c.name, "He-Man"
    c.name = "Skeletor"
    c.save
    c.destroy    
  end

  def test_proxy_works_with_singleton_and_prefix
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/resources.xml", {}, @resources_with_prefix_response
      mock.get "/someprefix/master.xml", {}, @master_response
      mock.post "/someprefix/master.xml", {}, @master_response, 201
      mock.put "/someprefix/master.xml", {}, nil, 204
      mock.delete "/someprefix/master.xml", {}, @master_response, 200
    end
    
    @proxy = YaST::ServiceResource.proxy_for("org.yast.master")
    assert @proxy.singular?

    assert_equal "http://localhost:8080/someprefix", @proxy.site.to_s

    c = @proxy.find   
    # only one
    assert_not_equal c.class, Array
    assert_equal c.name, "He-Man"
    c.name = "Skeletor"
    c.save
    c.destroy
  end

  
  def test_proxy_uses_prefix
    ActiveResource::HttpMock.respond_to do |mock|
      # the resources are returned prefixed from the server
      mock.get "/resources.xml", {}, @resources_with_prefix_response
      # however we only respond to the root ones
      mock.get "/foos.xml", {}, @foos_response
      mock.get "/foos/1.xml", {}, @foo_response
    end
    @proxy = YaST::ServiceResource.proxy_for("org.yast.foo")
    # therefore this has to fail because the proxy should look into the
    # prefix and not root
    assert_raise ActiveResource::InvalidRequestError do 
      @proxy.find(:all).first.bar
    end
  end

  def test_proxy_works_with_prefix
    ActiveResource::HttpMock.respond_to do |mock|
      # the resources are returned prefixed from the server
      mock.get "/resources.xml", {}, @resources_with_prefix_response
      # however we respond to the prefixed ones
      mock.get "/someprefix/foos.xml", {}, @foos_response
      mock.get "/someprefix/foos/1.xml", {}, @foo_response
    end
    @proxy = YaST::ServiceResource.proxy_for("org.yast.foo")
    # this has to work now
    assert_equal "Hello", @proxy.find(:all).first.bar
  end

  def test_permissions
    permissions_response = <<EOF
      <permissions type=\"array\">
        <permission>
          <id>org.yast.foo.read</id>
          <granted type=\"boolean\">true</granted>
        </permission>
        <permission>
          <id>org.yast.foo.write</id>
         <granted type=\"boolean\">false</granted>
        </permission>
      </permissions>
EOF
    ActiveResource::HttpMock.respond_to do |mock|
      # the resources are returned prefixed from the server
      mock.get "/resources.xml", {}, @resources_with_prefix_response
      # however we respond to the prefixed ones
      #mock.get "/permissions.xml", {}, permissions_response
      # ARGH httpmock does not support paramters
      mock.get "/permissions.xml?filter=org.yast.foo&user_id=linus", {}, permissions_response
      mock.get "/someprefix/foos/1.xml", {}, @foo_response
    end
    @proxy = YaST::ServiceResource.proxy_for("org.yast.foo")

    perms = @proxy.permissions
    assert_not_nil perms
    assert_equal Hash, perms.class
    assert perms.has_key?(:read)
    assert perms.has_key?(:write)
    assert ! perms.has_key?(:other)
    assert perms[:read]
    assert ! perms[:write]
  end
  
  def test_proxy_works_with_array_attrs
    master_with_array_attr_response = <<FIN
      <master>
        <name>He-Man</name>
        <cities type=\"array\">
          <city>Santiago</city>
          <city>Nuernberg</city>
        </cities>
      </master>
FIN
    ActiveResource::HttpMock.respond_to do |mock|
      mock.put "/master.xml", {}, nil, 200
      mock.get "/resources.xml", {}, @resources_response
      mock.get "/master.xml", {}, master_with_array_attr_response
      mock.post "/master.xml", {}, master_with_array_attr_response, 201
      mock.delete "/master.xml", {}, master_with_array_attr_response, 200
    end
    
    @proxy = YaST::ServiceResource.proxy_for("org.yast.master")
    assert @proxy.singular?
    c = @proxy.find
    assert Array, c.cities.class
  end

  def test_proxy_works_with_status_page
    @status_response = <<EOFA
<status>
  <memory>
  <memoryused>
    <value>
      <T_1246965500>5.9948777472e+08</T_1246965500>
      <T_1246964500>6.0554035200e+08</T_1246964500>
      <T_1246965000>6.0168527872e+08</T_1246965000>
    </value>
    </memoryused>
  </memory>
</status>
EOFA

     @resources_status_response = <<EOFB
      <resources type=\"array\">
        <resource>
          <interface>org.yast.status</interface>
          <policy/>
          <singular type="boolean">true</singular>
          <href>/status</href>
        </resource>
      </resources>
EOFB
    
    ActiveResource::HttpMock.respond_to do |mock|
      mock.put "/status.xml", {}, nil, 200
      mock.get "/status.xml", {}, @status_response
      mock.get "/resources.xml", {}, @resources_status_response
    end
    
    @proxy = YaST::ServiceResource.proxy_for("org.yast.status")
    # the proxy is an anonymous class
    assert @proxy.singular?
    c = @proxy.find
    # only one
    assert_not_equal c.class, Array

# FIXME    assert_equal c.memory.memoryused.value.t_1246965000, "6.0168527872e+08"
    #c.save
    #c.destroy    
  end

end
