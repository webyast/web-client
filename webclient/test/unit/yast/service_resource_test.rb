
require 'test_helper'
require 'yast/service_resource'
require 'active_resource/http_mock'

class YaSTServiceResourceBaseTest < ActiveSupport::TestCase
  def setup
    YaST::ServiceResource::Session.site = "http://localhost:8080"
    # first define the resources the server would returl
    @resources_response = "<resources type=\"array\"><resource><interface>org.yast.foo</interface><href>/foos</href></resource></resources>"
    @resources_with_prefix_response = "<resources type=\"array\"><resource><interface>org.yast.foo</interface><href>/someprefix/foos</href></resource></resources>"
    @foos_response = "<foos type=\"array\"><foo><bar>Hello</bar></foo><foo><bar>Goodbye</bar></foo></foos>"
    @foo_response = "<foo><bar>Bye</bar></foo>"
    # simulate that we are logged to a service
    YaST::ServiceResource::Session.site = "http://localhost:8080"
    
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
  
end
