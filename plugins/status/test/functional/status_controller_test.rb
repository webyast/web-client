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
    @response_logs = fixture "logs.xml"
    @response_graphs = fixture "graphs.xml"
    @response_graphs_memory = fixture "graphs_memory.xml"
    @response_metrics_memory_free = fixture "waerden+memory+memory-free.xml"
    @response_metrics_memory_used = fixture "waerden+memory+memory-used.xml"
    @response_metrics_memory_cached = fixture "waerden+memory+memory-used.xml"
    @response_metrics = fixture "metrics.xml"
    @response_writing_limits = fixture "memory_write.xml"
    ActiveResource::HttpMock.set_authentication
    @header = ActiveResource::HttpMock.authentication_header
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources  :"org.opensuse.yast.system.logs" => "/logs", :"org.opensuse.yast.system.metrics" => "/metrics", :"org.opensuse.yast.system.graphs" => "/graphs"
      mock.permissions "org.opensuse.yast.system.status", { :read => true, :writelimits => true }
      mock.get "/logs.xml", @header, @response_logs, 200
      mock.get "/graphs.xml?checklimits=true", @header, @response_graphs, 200
      mock.get "/graphs.xml", @header, @response_graphs, 200
      mock.get "/graphs/Memory.xml", @header, @response_graphs_memory, 200
      mock.put "/graphs/Memory.xml", @header, @response_writing_limits, 200
      mock.get "/metrics.xml", @header, @response_metrics, 200
      mock.get "/metrics/waerden+memory+memory-free.xml?start=1264006320&stop=1264006620", @header, @response_metrics_memory_free, 200
      mock.get "/metrics/waerden+memory+memory-used.xml?start=1264006320&stop=1264006620", @header, @response_metrics_memory_used, 200
      mock.get "/metrics/waerden+memory+memory-cached.xml?start=1264006320&stop=1264006620", @header, @response_metrics_memory_cached, 200
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

  # now permissions in index
  def test_index_no_permissions
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources  :"org.opensuse.yast.system.logs" => "/logs", :"org.opensuse.yast.system.metrics" => "/metrics", :"org.opensuse.yast.system.graphs" => "/graphs"
      mock.permissions "org.opensuse.yast.system.status", { :read => false, :writelimits => false }
      mock.get   "/logs.xml", @header, @response_logs, 200
      mock.get   "/graphs.xml?checklimits=true", @header, @response_graphs, 200
      mock.get   "/graphs.xml", @header, @response_graphs, 200
      mock.get   "/metrics.xml", @header, @response_metrics, 200
    end

    get :index
    assert_response :success
    assert_valid_markup
    assert assigns(:graphs)
  end

  #testing show summary AJAX call; OK
  def test_show_summary
    get :show_summary
    assert_response :success
    assert_valid_markup
    assert_tag :tag =>"div",
               :attributes => { :class => "status-icon ok" }
    assert_tag "Your system is healthy."
  end

  #testing show summary AJAX call; limit CPU user reached
  def test_show_summary_limit_reached
    response_graphs = fixture "graphs_limits_reached.xml"
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources  :"org.opensuse.yast.system.logs" => "/logs", :"org.opensuse.yast.system.metrics" => "/metrics", :"org.opensuse.yast.system.graphs" => "/graphs"
      mock.permissions "org.opensuse.yast.system.status", { :read => true, :writelimits => true }
      mock.get   "/logs.xml", @header, @response_logs, 200
      mock.get   "/graphs.xml?checklimits=true", @header, response_graphs, 200
      mock.get   "/graphs.xml", @header, response_graphs, 200
      mock.get   "/metrics.xml", @header, @response_metrics, 200
    end

    get :show_summary
    assert_response :success
    assert_valid_markup
    assert_tag :tag =>"div",
               :attributes => { :class => "status-icon error" }
    assert_tag "Limits exceeded for CPU/CPU-0/user"
  end

  #testing evaluate_values AJAX call
  def test_show_evaluate_values
    Time.stubs(:now).returns(Time.at(1264006620))
    get :evaluate_values,  { :group_id => "Memory", :graph_id => "Memory" } 
    assert_response :success
    assert_valid_markup
    assert_tag :tag =>"script",
               :attributes => { :type => "text/javascript" }
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

    get :index
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

    get :index
    assert_response :success
    assert_valid_markup
    assert_tag "collectd is not running on the target machine"
  end

  #call for edit limits
  def test_edit
    get :edit
    assert_response :success
    assert_valid_markup
    assert assigns(:graphs)
  end

  #writing limits
  def test_commit_limits
    put :save,  {"value/Memory/Memory/cached"=>"", "measurement/CPU/CPU-0/user"=>"max", "value/CPU/CPU-0/user"=>"", "value/CPU/CPU-1/user"=>"", "value/Network/eth0/received"=>"", "measurement/CPU/CPU-1/idle"=>"max", "measurement/CPU/CPU-0/idle"=>"max", "measurement/Network/eth0/sent"=>"max", "value/CPU/CPU-1/idle"=>"", "measurement/Network/eth0/received"=>"max", "measurement/Memory/Memory/free"=>"min", "measurement/Memory/Memory/used"=>"max", "value/Memory/Memory/used"=>"", "value/CPU/CPU-0/idle"=>"", "value/Network/eth0/sent"=>"", "value/Memory/Memory/free"=>"40", "measurement/Memory/Memory/cached"=>"max", "measurement/CPU/CPU-1/user"=>"max"}
    assert_response :redirect
    assert_redirected_to :controller => "status", :action => "index"
  end


end
