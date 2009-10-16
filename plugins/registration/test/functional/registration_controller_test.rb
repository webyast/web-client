require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'rubygems'
require 'mocha'



class RegistrationControllerTest < ActionController::TestCase
 # fixtures :accounts

  class Proxy
    attr_accessor :result, :permissions, :timeout
    def save
      result
    end
    def create dummy1
      result
    end
    def new dummy1
      result
    end
  end

  class Result
    attr_accessor :status,
      :exitcode,
      :missingarguments,
      :saved

    def fill
      @status = 'missinginfo'
      @exitcode = 0,
      @missingarguments =[{'name'=>'Email', 'type'=>'string'},
                          {'name'=>'Registration Name', 'type'=>'string'},
                          {'name'=>'System Name', 'type'=>'string'}]
    end
    def save
      @saved = true
    end
    def to_xml
      "xml output"
    end
  end



  def setup
    RegistrationController.any_instance.stubs(:login_required)
    @controller = RegistrationController.new
    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures
    @permissions = { :statelessregister => true }
    @result = Result.new
    @result.fill
    @proxy = Proxy.new
    @proxy.permissions = @permissions
    @proxy.result = @result
  end
  
  def test_access_index
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.registration.registration').returns(@proxy)
    get :index

    #check if everything have been correctly set
    assert_response :success
    assert_valid_markup
    assert assigns(:permissions) , "Permission is not set"
    assert assigns(:permissions)[:statelessregister], ":statelessregister permission is not set"
  end

  def test_access_without_statelessregister_permissions
    @permissions[:statelessregister] = false
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.registration.registration').returns(@proxy)

    get :index

    assert_response 302
    assert_valid_markup
    assert assigns(:permissions)
    assert !assigns(:permissions)[:statelessregister]
  end


  def test_register
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.registration.registration').returns(@proxy)
    post :update, {"registration_arg,Registration Name"=>"registrationName", "registration_arg,System Name"=>"systemName", "registration_arg,Email"=>"email" }
    assert_response :success
  end

end
