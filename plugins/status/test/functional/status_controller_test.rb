require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'mocha'
require 'yast_mock'


class StatusControllerTest < ActionController::TestCase


  def setup
    StatusController.any_instance.stubs(:login_required)
    @controller = StatusController.new
    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures
    response_logs = IO.read(File.join(File.dirname(__FILE__),"..","fixtures","logs.xml"))
    response_graphs = IO.read(File.join(File.dirname(__FILE__),"..","fixtures","graphs.xml"))
    response_metrics = IO.read(File.join(File.dirname(__FILE__),"..","fixtures","metrics.xml"))
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.system.logs" => "/logs", :"org.opensuse.yast.system.metrics" => "/metrics", :"org.opensuse.yast.system.graphs" => "/graphs"
      mock.permissions "org.opensuse.yast.system.status", { :read => true, :writelimits => true }
      mock.get   "/logs.xml", header, response_logs, 200
      mock.get   "/graphs.xml", header, response_graphs, 200
      mock.get   "/metrics.xml", header, response_metrics, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_index
    get :index
#    assert_response :success
#    assert_valid_markup
#    assert assigns(:graphs)
  end



#OUT_SYNC_ERROR = <<EOF
#<error>
#  <type>COLLECTD_SYNC_ERROR</type>
#  <description>blba bla</description>
#</error>
#EOF
#
#class ResponseMock
#  def body
#    return OUT_SYNC_ERROR
#  end
#
#  def code
#    return "503"
#  end
#end
#
#status module must survive collectd out of sync
#  def test_collectd_out_of_sync
#    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.system.logs').returns(@logs_proxy)
#    sproxy = StatusProxy.new
#    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.system.status').returns(sproxy)
#    sproxy.stubs(:find).raises(ActiveResource::ServerError.new(ResponseMock.new,""))
#    get :index
#    assert_response :success       will be obsolete
#    assert_valid_markup
#    assert assigns(:logs)
#  end

end
