require 'test_helper'

class ServicesControllerTest < ActionController::TestCase


  class Proxy
    attr_accessor :result, :permissions, :timeout
    def find
      return result
    end
  end

  def setup
    ServicesController.any_instance.stubs(:login_required)
    @controller = ServicesController.new
    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures
    @permissions = { :read => true, :execute => true }
    @proxy = Proxy.new
    @proxy.permissions = @permissions
    @proxy.result = @result
  end

  def test_should_get_index
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.yapi.services').returns(@proxy)
    get :index
    assert_response :success
    assert_not_nil assigns(:services)
  end

end
