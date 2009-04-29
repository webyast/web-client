
require 'test_helper'
require 'yast/service_resource'
require 'active_resource/http_mock'

class YaSTServiceResourceBaseTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_proxy
    resources_response = "<resources type=\"array\"><resource><interface>org.yast.foo</interface><href>/foos</href></resource></resources>"
    foos_response = "<foos type=\"array\"><foo><bar>Hello</bar></foo></foos>"
    foo_response = "<foo><bar>Bye</bar></foo>"
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get "/resources.xml", {}, resources_response
      mock.get "/foos.xml", {}, foos_response
      mock.get "/foos/1.xml", {}, foo_response
    end
    proxy = YaST::ServiceResource.proxy_for("org.yast.foo")
    assert_equal proxy.find(:all).class, Array
    assert_equal proxy.find(:all).first.bar, "Hello"
  end
end
