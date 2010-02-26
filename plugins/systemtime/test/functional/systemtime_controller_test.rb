require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'mocha'
require 'yast_mock'

class SystemtimeControllerTest < ActionController::TestCase
  
  def setup
    Ntp.instance_variable_set(:@permissions,nil) #reset permissions cache
    Systemtime.instance_variable_set(:@permissions,nil) #reset permissions cache
    SystemtimeController.any_instance.stubs(:login_required)
    @controller = SystemtimeController.new
    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures
    @response_time = IO.read(File.join(File.dirname(__FILE__),"..","fixtures","systemtime.xml"))
    @response_ntp = IO.read(File.join(File.dirname(__FILE__),"..","fixtures","ntp.xml"))
    ActiveResource::HttpMock.set_authentication
    @header = ActiveResource::HttpMock.authentication_header
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources  :"org.opensuse.yast.modules.yapi.time" => "/systemtime", :"org.opensuse.yast.modules.yapi.ntp" => "/ntp"
      mock.permissions "org.opensuse.yast.modules.yapi.time", { :read => true, :write => true }
      mock.permissions "org.opensuse.yast.modules.yapi.ntp", { :available => true, :synchronize => true }
      mock.get   "/systemtime.xml", @header, @response_time, 200
      mock.post   "/systemtime.xml", @header, @response_time, 200
      mock.get   "/ntp.xml", @header, @response_ntp, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_index
    get :index
    assert_response :success
    assert_valid_markup
    assert assigns(:stime)
    #check if values is really read from rest-service
    assert ActiveResource::HttpMock.requests.any? {
        |r| r.method == :get && r.path == "/systemtime.xml"},
      "missing request for time on rest-service. \n Requests: #{ActiveResource::HttpMock.requests.inspect}"
    assert ActiveResource::HttpMock.requests.any? {
        |r| r.method == :get && r.path == "/ntp.xml"},
      "missing request for ntp on rest-service. \n Requests: #{ActiveResource::HttpMock.requests.inspect}"
  end

  def test_timezone_change #bnc#582810
    post :update, { :region => "Africa", :timezone => "Kampala" }
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "index"
    rq = ActiveResource::HttpMock.requests.find {
        |r| r.method == :post && r.path == "/systemtime.xml"}
    assert rq #commit request send
    assert rq.body
    params = Hash.from_xml(rq.body)["systemtime"]
    assert_equal params["timezone"],"Africa/Kampala" 
    #ntp is not called if time settings is empty
    assert !ActiveResource::HttpMock.requests.any? {
        |r| r.method == :post && r.path == "/ntp.xml"}
  end

  def test_commit
    post :update, { :currenttime => "12:18:00", :date => { :date => "2009-07-02" }, :timeconfig => ""}
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "index"
    rq = ActiveResource::HttpMock.requests.find {
        |r| r.method == :post && r.path == "/systemtime.xml"}
    assert rq #commit request send
    assert rq.body
    params = Hash.from_xml(rq.body)["systemtime"]
    assert_nil params["time"] #empty because manual settings of time is not set
    assert_nil params["date"] #empty because manual settings of time is not set
    #ntp is not called if time settings is empty
    assert !ActiveResource::HttpMock.requests.any? {
        |r| r.method == :post && r.path == "/ntp.xml"}
  end

  def test_commit_wizard
    response_ntp_stop = IO.read(File.join(File.dirname(__FILE__),"..","..","..","services","test","fixtures","ntp.xml"))
    #add mock for services to stop ntp
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources  :"org.opensuse.yast.modules.yapi.time" => "/systemtime", :"org.opensuse.yast.modules.yapi.ntp" => "/ntp", :"org.opensuse.yast.modules.yapi.services" => "/services"
      mock.permissions "org.opensuse.yast.modules.yapi.time", { :read => true, :write => true }
      mock.permissions "org.opensuse.yast.modules.yapi.ntp", { :available => true, :synchronize => true }
      mock.permissions "org.opensuse.yast.modules.yapi.services", { :read => true, :write => true, :execute => true}
      mock.get   "/systemtime.xml", @header, @response_time, 200
      mock.post   "/systemtime.xml", @header, @response_time, 200
      mock.get   "/ntp.xml", @header, @response_ntp, 200
      mock.put	"/services/ntp.xml?execute=stop", @header, response_ntp_stop, 200
    end
    session[:wizard_current] = "test"
    session[:wizard_steps] = "systemtime,language"
    post :update, { :currenttime => "12:18:00", :date => { :date => "2009-07-02" }, :timeconfig => "manual"}
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "nextstep"
    rq = ActiveResource::HttpMock.requests.find {
        |r| r.method == :post && r.path == "/systemtime.xml"}
    assert rq #commit request send
    assert rq.body
    params = Hash.from_xml(rq.body)["systemtime"]
    assert_equal "12:18:00",params["time"] #empty because manual settings of time is not set
    assert_equal "2009-07-02",params["date"] #empty because manual settings of time is not set
    #ntp is not called if time settings is manual
    assert !ActiveResource::HttpMock.requests.any? {
        |r| r.method == :post && r.path == "/ntp.xml"}
  end

  def test_ntp
    response_ntp_stop = IO.read(File.join(File.dirname(__FILE__),"..","..","..","services","test","fixtures","ntp.xml"))
    #add mock for services to stop ntp
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources  :"org.opensuse.yast.modules.yapi.time" => "/systemtime", :"org.opensuse.yast.modules.yapi.ntp" => "/ntp", :"org.opensuse.yast.modules.yapi.services" => "/services"
      mock.permissions "org.opensuse.yast.modules.yapi.time", { :read => true, :write => true }
      mock.permissions "org.opensuse.yast.modules.yapi.ntp", { :available => true, :synchronize => true }
      mock.permissions "org.opensuse.yast.modules.yapi.services", { :read => true, :write => true, :execute => true}
      mock.get   "/systemtime.xml", @header, @response_time, 200
      mock.post   "/systemtime.xml", @header, @response_time, 200
      mock.get   "/ntp.xml", @header, @response_ntp, 200
      mock.post   "/ntp.xml", @header, @response_ntp, 200
      mock.put	"/services/ntp.xml?execute=start", @header, response_ntp_stop, 200
    end
    post :update, { :timeconfig => "ntp_sync" }
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "index"
    assert ActiveResource::HttpMock.requests.any? {
        |r| r.method == :post && r.path == "/ntp.xml"},
    #check that manual time is not sent
    rq = ActiveResource::HttpMock.requests.find {
        |r| r.method == :post && r.path == "/systemtime.xml"}
    assert rq #commit request send
    assert rq.body
    params = Hash.from_xml(rq.body)["systemtime"]
    assert_nil params["time"]
    assert_nil params["date"]
  end

end
