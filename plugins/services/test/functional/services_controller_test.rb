require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'yast_mock'
require 'mocha'

class ServicesControllerTest < ActionController::TestCase

  def setup
    ServicesController.any_instance.stubs(:login_required)
    @request = ActionController::TestRequest.new
    response_services	= IO.read(File.join(File.dirname(__FILE__),"..","fixtures","services.xml"))
    response_ntp	= IO.read(File.join(File.dirname(__FILE__),"..","fixtures","ntp.xml"))
    response_ntp_stop	= IO.read(File.join(File.dirname(__FILE__),"..","fixtures","ntp-stop.xml"))
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.services" => "/services"
      mock.permissions "org.opensuse.yast.modules.yapi.services", { :read => true, :write => true, :execute => true}
      mock.get   "/services.xml?read_status=1", header, response_services, 200
      mock.get   "/services/ntp.xml", header, response_ntp, 200
      mock.post  "/services.xml", header, response_services, 200
      mock.put	"/services/ntp.xml?execute=stop", header, response_ntp_stop, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_index
    get :index
    assert_response :success
    assert_valid_markup
    assert_not_nil assigns(:services)
  end

  def test_ntp_status
    ret = get :show_status, {:id => 'ntp'}
    assert_response :success
    assert !ret.body.index("not running").nil? # fixture status is 3 = not running
  end

  def test_execute
    put :execute, { :service_id => 'ntp', :id => 'stop'}
    assert assigns(:error_string), "success"
    assert assigns(:result_string), "Shutting down network time protocol daemon (NTPD)\n"
  end

end

