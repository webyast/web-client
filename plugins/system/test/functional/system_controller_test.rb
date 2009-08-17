require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'rubygems'

class SystemControllerTest < ActionController::TestCase

  class Proxy
    attr_accessor :result, :permissions, :timeout
    def find
      return result
    end
  end

  class Action
    attr_accessor :active

    def initialize
	@active = false 
    end
  end

  class Result
    attr_accessor :reboot, :shutdown

    def fill
	@reboot = Action.new
	@shutdown = Action.new
    end

    def save
      return true
    end
  end

  def setup
    @request = ActionController::TestRequest.new

    @result = Result.new
    @result.fill

    @proxy = Proxy.new
    @proxy.permissions = { :read => true, :write => true }
    @proxy.result = @result
 
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.system.system').returns(@proxy)

    @controller = SystemController.new
    SystemController.any_instance.stubs(:login_required)
  end
  
  test "'reboot' not accpeted via GET" do
    ret = get :reboot

    # redirected to the control panel?
    assert_response :found
    assert_redirected_to :controller => :controlpanel, :action => :index

    # error reported?
    assert !ret.flash[:error].blank?
  end

  test "'shutdown' not accpeted via GET" do
    ret = get :shutdown

    # redirected to the control panel?
    assert_response :found
    assert_redirected_to :controller => :controlpanel, :action => :index

    # error reported?
    assert !ret.flash[:error].blank?
  end

  test "check 'shutdown' result" do
    ret = put :shutdown

    # redirected to the control panel?
    assert_response :found
    assert_redirected_to :controller => :controlpanel, :action => :index

    # no error and a message present?
    assert ret.flash[:error].blank?
    assert !ret.flash[:message].blank?
  end

  test "check 'reboot' result" do
    ret = put :reboot

    # redirected to the control panel?
    assert_response :found
    assert_redirected_to :controller => :controlpanel, :action => :index

    # no error and a message present?
    assert ret.flash[:error].blank?
    assert !ret.flash[:message].blank?
  end

  test "check 'shutdown' failed" do
    Result.any_instance.stubs(:save).returns(false)
    ret = put :shutdown

    # redirected to the control panel?
    assert_response :found
    assert_redirected_to :controller => :controlpanel, :action => :index

    # error reported?
    assert !ret.flash[:error].blank?
    Result.any_instance.stubs(:save).returns(true)
  end

  test "check 'reboot' failed" do
    Result.any_instance.stubs(:save).returns(false)
    ret = put :reboot

    # redirected to the control panel?
    assert_response :found
    assert_redirected_to :controller => :controlpanel, :action => :index

    # error reported?
    assert !ret.flash[:error].blank?
    Result.any_instance.stubs(:save).returns(true)
  end

end
