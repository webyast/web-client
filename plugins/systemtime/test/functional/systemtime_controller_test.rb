require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'mocha'
require 'yast_mock'

class SystemtimeControllerTest < ActionController::TestCase
  
  def setup
    SystemtimeController.any_instance.stubs(:login_required)
    @controller = SystemtimeController.new
    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures
    response_time = IO.read(File.join(File.dirname(__FILE__),"..","fixtures","success.xml"))
    response_ntp = IO.read(File.join(File.dirname(__FILE__),"..","fixtures","ntp.xml"))
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.time" => "/systemtime", :"org.opensuse.yast.modules.yapi.ntp" => "/ntp"
      mock.permissions "org.opensuse.yast.modules.yapi.time", { :read => true, :write => true }
      mock.permissions "org.opensuse.yast.modules.yapi.ntp", { :available => true, :synchronize => true }
      mock.get   "/systemtime.xml", header, response_time, 200
      mock.post   "/systemtime.xml", header, response_time, 200
      mock.get   "/ntp.xml", header, response_ntp, 200
      mock.post   "/ntp.xml", header, response_ntp, 200
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
  end

  def test_commit
    post :update, { :currenttime => "12:18:00", :date => { :date => "2009-07-02" } }
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "index"
  end

  def test_commit_wizard
    session[:wizard_current] = "test"
    session[:wizard_steps] = "systemtime,language"
    post :update, { :currenttime => "12:18:00", :date => { :date => "2009-07-02" }}

    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "nextstep"
  end

  def test_ntp
    post :update, { :timeconfig => "ntp_sync" }
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "index"
  end

end
