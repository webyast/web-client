require 'test_helper'

class ServicesControllerTest < ActionController::TestCase

  class Proxy
    attr_accessor :result, :permissions, :timeout
    def find(params = {})
      return result
    end
  end

  class Result
    attr_accessor :status

    def fill
	@status = 0
    end

    def save
      return true
    end
  end

  def setup
    @result = Result.new
    @result.fill

    ServicesController.any_instance.stubs(:login_required)
    @controller = ServicesController.new

    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures

    @permissions = { :read => true, :execute => true }
    @proxy = Proxy.new
    @proxy.permissions = @permissions
    @proxy.result = @result

    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.yapi.services').returns(@proxy)
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:services)
  end


  def test_ntp_status
    ret = get :show_status, {:id => 'ntp'}
    assert_response :success
    assert ret.body == '(running)'
  end

end
