require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'mocha'
require 'yast_mock'


class StatusControllerTest < ActionController::TestCase

  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    StatusController.any_instance.stubs(:login_required)
    @controller = StatusController.new
    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures
    response_logs = fixture "logs.xml"
    response_graphs = fixture "graphs.xml"
    response_metrics = fixture "metrics.xml"
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      @header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.system.logs" => "/logs", :"org.opensuse.yast.system.metrics" => "/metrics", :"org.opensuse.yast.system.graphs" => "/graphs"
      mock.permissions "org.opensuse.yast.system.status", { :read => true, :writelimits => true }
      mock.get   "/logs.xml", @header, response_logs, 200
      mock.get   "/graphs.xml?checklimits=true", @header, response_graphs, 200
      mock.get   "/graphs.xml", @header, response_graphs, 200
      mock.get   "/metrics.xml", @header, response_metrics, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  #first index call
  def test_index
    get :index
    assert_response :success
    assert_valid_markup
    assert assigns(:graphs)
  end

  # status module must survive collectd out of sync
  def test_collectd_out_of_sync
    response_graphs = fixture "out_sync_error.xml"
    response_metrics = fixture "out_sync_error.xml"
    response_logs = fixture "logs.xml"

    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources  :"org.opensuse.yast.system.logs" => "/logs", :"org.opensuse.yast.system.metrics" => "/metrics", :"org.opensuse.yast.system.graphs" => "/graphs"
      mock.permissions "org.opensuse.yast.system.status", { :read => true, :writelimits => true }
      mock.get   "/logs.xml", @header, response_logs, 200
      mock.get   "/graphs.xml?checklimits=true", @header, response_graphs, 503
      mock.get   "/graphs.xml", @header, response_graphs, 503
      mock.get   "/metrics.xml", @header, response_metrics, 503
    end

    ret = get :index
    assert_response :success
    assert_valid_markup
    assert_tag "Collectd is out of sync. Status information can be expected at Wed Jan 20 22:34:38 2010."

  end

  # status module must survive SERVICE_NOT_RUNNING
  def test_collectd_service_not_running
    response_graphs = fixture "service_not_running.xml"
    response_metrics = fixture "service_not_running.xml"
    response_logs = fixture "logs.xml"

    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources  :"org.opensuse.yast.system.logs" => "/logs", :"org.opensuse.yast.system.metrics" => "/metrics", :"org.opensuse.yast.system.graphs" => "/graphs"
      mock.permissions "org.opensuse.yast.system.status", { :read => true, :writelimits => true }
      mock.get   "/logs.xml", @header, response_logs, 200
      mock.get   "/graphs.xml?checklimits=true", @header, response_graphs, 503
      mock.get   "/graphs.xml", @header, response_graphs, 503
      mock.get   "/metrics.xml", @header, response_metrics, 503
    end

    ret = get :index
    assert_response :success
    assert_valid_markup
    assert_tag "collectd is not running on the target machine"
  end

end
