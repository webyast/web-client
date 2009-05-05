
require 'test_helper'
require 'yast/service_resource'
require 'active_resource/http_mock'

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
          <href>/foos</href>
        </resource>
        <resource>
          <interface>org.yast.master</interface>
          <href>/master</href>
        </resource>
      </resources>
EOF
    @resources_with_prefix_response = <<EOF
      <resources type=\"array\">
        <resource>
          <interface>org.yast.foo</interface>
          <href>/someprefix/foos</href>
        </resource>
        <resource>
          <interface>org.yast.master</interface>
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
  
  def test_proxy_works
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/resources.xml", {}, @resources_response
      mock.get "/foos.xml", {}, @foos_response
      mock.get "/foos/1.xml", {}, @foo_response
    end
    
    @proxy = YaST::ServiceResource.proxy_for("org.yast.foo")
    # the proxy is an anonymous class
    assert_equal "Class", @proxy.class.to_s
    # the proxy should work returning collections
    c = @proxy.find(:all)
    assert_equal c.class, Array
    assert_equal 2, c.size
    assert_equal "Hello", c.first.bar
  end

  def test_proxy_works_with_singleton
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/resources.xml", {}, @resources_response
      mock.get "/master.xml", {}, @master_response
    end
    
    @proxy = YaST::ServiceResource.proxy_for("org.yast.master")
    # the proxy is an anonymous class
    c = @proxy.find(:one)
    # only one
    assert_not_equal c.class, Array
    assert_equal c.name, "He-Man"
  end

  def test_proxy_works_with_singleton_and_prefix
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/resources.xml", {}, @resources_with_prefix_response
      mock.get "/someprefix/master.xml", {}, @master_response
    end
    
    @proxy = YaST::ServiceResource.proxy_for("org.yast.master")
    # the proxy is an anonymous class
    c = @proxy.find(:one)
    # only one
    assert_not_equal c.class, Array
    assert_equal c.name, "He-Man"
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

  
end
