require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )

class ServicesControllerTest < ActionController::TestCase

  class Proxy
    attr_accessor :result, :permissions, :timeout
    def find(arg, params = {})
      if arg == :all
        return [result]
      else
        return result
      end
    end
  end

  class Proxy2
    attr_accessor :result, :permissions, :timeout
    def find(arg, params = {})
      raise ActiveResource::ResourceNotFound.new(Net::HTTPNotFound.new('1.1', '404', 'Not Found '))
    end
  end

  class Result
    attr_accessor :status, :name, :description, :summary

    def fill
	@status = 0
        @name = "fake-service"
        @description = "a fake service"
	@summary	= ""
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

    @proxy2 = Proxy2.new
    @proxy2.permissions = @permissions
    @proxy2.result = @result
  end

  def test_should_get_index
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.yapi.services').returns(@proxy)
    get :index
    assert_response :success
    assert_valid_markup
    assert_not_nil assigns(:services)
  end


  def test_ntp_status
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.yapi.services').returns(@proxy)
    ret = get :show_status, {:id => 'ntp'}
    assert_response :success
    assert !ret.body.index("running").nil?
  end

  def test_missing_service_status
    Net::HTTPNotFound.any_instance.stubs(:body).returns("<error><code>108</code><message>Missing custom command to 'status' command</message></error>")
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.yapi.services').returns(@proxy2)
    ret = get :show_status, {:id => 'aaaaaaaa'}
    assert_response :success
    assert ret.body == '(cannot read status)'
  end

end

