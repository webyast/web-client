require File.dirname(__FILE__) + '/../test_helper'

require 'mocha'

class BasesystemControllerTest < ActionController::TestCase
  
  class Proxy
    attr_accessor :result, :permissions, :timeout

    def initialize (result, permissions)
      @result = result
      @permissions = permissions
    end

    def find
      return @result
    end
  end

  class Result
    attr_accessor :steps, :finish, :saved

    def initialize (steps, finish)
      @steps = steps
      @finish = finish
      @saved = false
    end

    def save
      @saved = true
    end
  end

  class Step
    attr_accessor :controller, :action

    def initialize (controller, action = nil)
      @controller = controller
      @action = action
    end
  end


  def setup
    ControlpanelController.any_instance.stubs(:ensure_login)
    @controller = ControlpanelController.new
    #@request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    #@request.session[:account_id] = 1 # defined in fixtures

    # setup for basesystem tests
    @result = Result.new([Step.new("systemtime"), Step.new("language", "show")], true)
    @proxy = Proxy.new(@result, {:read=>true, :write=>true})
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.basesystem').returns(@proxy)
  end

  test "basesystem start" do
    @result.finish = false
    get :index
    assert_redirected_to "/systemtime"
    assert_not_nil session[:wizard_current]
    assert_not_nil session[:wizard_steps]
  end

  test "basesystem ensure wizard" do
    @result.finish = false
    get :nextstep
    assert_redirected_to "/controlpanel"
  end

  test "basesystem thisstep" do
    @result.finish = false
    get :index
    get :thisstep
    assert_response :redirect
    assert_redirected_to "/systemtime"
  end

  test "basesystem next" do
    @result.finish = false
    get :index
    get :nextstep
    assert_response :redirect
    assert_redirected_to "/language/show"
  end

  test "basesystem finish" do
    @result.finish = false
    get :index
    get :nextstep
    get :nextstep
    assert @result.finish
    assert @result.saved
  end
end
