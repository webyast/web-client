require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'rubygems'
require 'mocha'



class RegistrationControllerTest < ActionController::TestCase
 # fixtures :accounts

  class Proxy
    attr_accessor :result, :permissions, :timeout
    def find
      return result
    end
  end


  def setup
    RegistrationController.any_instance.stubs(:login_required)
    @controller = RegistrationController.new
    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures
    @permissions = { :statelessregister => true }
#    @result = Result.new
#    @result.fill
    @proxy = Proxy.new
    @proxy.permissions = @permissions
    @proxy.result = @result
  end
  
  def test_access_index
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.registration').returns(@proxy)
    get :index

    #check if everything is correctly setted
#    assert_response :success
#    assert_valid_markup
#    assert assigns(:permissions) , "Permission is not set"
#    assert assigns(:permissions)[:statelessregister], ":statelessregister permission is not set"
  end

  def test_access_without_write_permissions
    @permissions[:write] = false
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.registration').returns(@proxy)

    get :index

#    assert_response :success
#    assert_valid_markup
#    assert assigns(:permissions)
#    assert assigns(:permissions)[:statelessregister]

  end


  def test_update
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.registration').returns(@proxy)
#    post :update, { }

#    assert_response :redirect
#    assert_redirected_to :action => "index"
#    assert @result.saved
  end

end
