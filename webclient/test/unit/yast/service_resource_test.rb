
require 'test_helper'
require 'yast/service_resource'
require 'active_resource/http_mock'

class Item < ActiveResource::Base
  self.site = "http:://localhost:8080"  
end


class YaSTServiceResourceBaseTest < ActiveSupport::TestCase
  def setup
    # simulate we are loggedin
    YaST::ServiceResource::Session.site = "http://localhost:8080"
    YaST::ServiceResource::Session.login = "linus"
    # first define the resources the server would return
    # we have a resource /foos and a singleton /master
    @resources_response = <<EOF
      <resources type=\"array\">
        <resource>
          <interface>org.yast.foo</interface>
          <singular type="boolean">false</singular>
          <href>/foos</href>
        </resource>
        <resource>
          <interface>org.yast.master</interface>
          <singular type="boolean">true</singular>
          <href>/master</href>
        </resource>
      </resources>
EOF
    @resources_with_prefix_response = <<EOF
      <resources type=\"array\">
        <resource>
          <interface>org.yast.foo</interface>
          <singular type="boolean">false</singular>
          <href>/someprefix/foos</href>
        </resource>
        <resource>
          <interface>org.yast.master</interface>
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
    YaST::ServiceResource::Session.site = "http://localhost:8080"
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  #def test_ar
  #  item_response = "<item><name>He-Man</name></item>"
  #  ActiveResource::HttpMock.respond_to do |mock|
  #    mock.get "/item.xml", {}, item_response
  #    mock.post "/item.xml", {}, item_response, 201
  #    mock.delete "/item.xml", {}, item_response, 200
  #  end
#
#    #m = Item.find(:one, :from => "/item.xml")
#    m = Item.find(:all)
#    assert_equal "dddddd", m.class 
#  end
  
  def test_proxy_works
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/resources.xml", {}, @resources_response
      mock.get "/foos.xml", {}, @foos_response
      mock.get "/foos/1.xml", {}, @foo_response
    end
    
    @proxy = YaST::ServiceResource.proxy_for("org.yast.foo")
    assert_equal "Class", @proxy.class.to_s
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
          <name>org.yast.foo.read</name>
          <grant type=\"boolean\">true</grant>
        </permission>
        <permission>
          <name>org.yast.foo.write</name>
         <grant type=\"boolean\">false</grant>
        </permission>
      </permissions>
EOF
    ActiveResource::HttpMock.respond_to do |mock|
      # the resources are returned prefixed from the server
      mock.get "/resources.xml", {}, @resources_with_prefix_response
      # however we respond to the prefixed ones
      mock.get "/permissions.xml", {}, permissions_response
      # ARGH httpmock does not support paramters
      #mock.get "/permissions.xml?user_id=linus&filter=org.yast.foo", {}, permissions_response
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

  
end
