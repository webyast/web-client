require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
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
    attr_accessor :status, :exitcode, :saved,
      :missingarguments, :changed_services, :changed_repositories

    def fill_missing
      @status = 'missinginfo'
      @exitcode = 4,
      @missingarguments =[{'name'=>'Email', 'type'=>'string'},
                          {'name'=>'Registration Name', 'type'=>'string'},
                          {'name'=>'System Name', 'type'=>'string'}]
    end

    def fill_false
      @status = 'missinginfo'
      @exitcode = 4,
      @missingarguments = [nil, nil]
    end

    def fill_success
      @status = "finished"
      @exitcode = 0
      @changed_repositories = []
      @changed_services = [ { "name"=>"nu_novell_com", "url"=>"https://nu.novell.com", "type"=>"nu", "alias"=>"nu_novell_com", "status"=>"added",
                              "catalogs" => {
                                "catalog" => [ { "name"=>"SLES11-SP1-Pool", "alias"=>"nu_novell_com:SLES11-SP1-Pool", "status"=>"added"},
                                               {"name"=>"SLES11-SP1-Updates", "alias"=>"nu_novell_com:SLES11-SP1-Updates", "status"=>"added"} 
                                             ] } 
                            } ]
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
    @proxy = Proxy.new
    @proxy.permissions = @permissions
    @proxy.result = @result
  end
  
  def test_access_index
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.registration.registration').returns(@proxy)
    @proxy.result.fill_missing
    get :index

    #check if everything have been correctly set
    assert_response :redirect
    assert_valid_markup
    assert assigns(:permissions) , "Permission is not set"
    assert assigns(:permissions)[:statelessregister], ":statelessregister permission is not set"
  end

  def test_access_without_statelessregister_permissions
    @permissions[:statelessregister] = false
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.registration.registration').returns(@proxy)
    @proxy.result.fill_missing

    get :index

    assert_response 302
    assert_valid_markup
    assert assigns(:permissions)
    assert !assigns(:permissions)[:statelessregister]
  end


  def test_register
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.registration.registration').returns(@proxy)
    @proxy.result.fill_success
    post :update, {"registration_arg,Registration Name"=>"registrationName", "registration_arg,System Name"=>"systemName", "registration_arg,Email"=>"email" }
    assert_response :redirect
    assert_redirected_to :action => "index"
  end

  def test_register_in_basesystem
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.registration.registration').returns(@proxy)
    @proxy.result.fill_success
    session[:wizard_current] = "test"
    session[:wizard_steps] = "language,registration"

    post :update, {"registration_arg,Registration Name"=>"registrationName", "registration_arg,System Name"=>"systemName", "registration_arg,Email"=>"email" }
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "nextstep"
  end

  def test_register_with_false_arguments
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.registration.registration').returns(@proxy)
    @proxy.result.fill_false

    get :index

    assert_response :redirect
    assert_valid_markup
  end

  def test_register_success
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.registration.registration').returns(@proxy)
    @proxy.result.fill_success

    get :index

    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "index"
    assert_valid_markup
  end

end
