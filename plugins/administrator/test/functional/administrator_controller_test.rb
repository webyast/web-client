require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'yast_mock'
require 'mocha'

class AdministratorControllerTest < ActionController::TestCase

  def setup
    AdministratorController.any_instance.stubs(:login_required)
    @request = ActionController::TestRequest.new
    @response_admin= IO.read(File.join(File.dirname(__FILE__),"..","fixtures","empty.xml"))
    response_mail= IO.read(File.join(File.dirname(__FILE__),"..","fixtures","mail-empty.xml"))
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.administrator" => "/administrator", :"org.opensuse.yast.modules.yapi.mailsettings" => "/mail"
      mock.permissions "org.opensuse.yast.modules.yapi.administrator", { :read => true, :write => true }
      mock.get   "/administrator.xml", header, @response_admin, 200
      mock.get   "/mail.xml", header, response_mail, 200
      mock.post  "/administrator.xml", header, @response_admin, 200
    end
  end

  def test_index
    get :index
    assert_response :success
    assert_valid_markup
    assert assigns(:administrator)
  end

  # alias should be reset to NONE, password not empty
  def test_commit_without_aliases
    post :update, { :administrator => {:aliases => "", :password => "a", :confirm_password => "a" } }
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "index"
    rq = ActiveResource::HttpMock.requests.find {
	|r| r.method == :post && r.path == "/administrator.xml"
    }
    assert rq #commit request send
    assert rq.body
    hash = Hash.from_xml(rq.body)["administrator"]
    assert_equal hash["aliases"], "NONE"
    assert hash["password"]
  end

  # test 'Save Mail' only, password should be nil
  def test_commit_only_aliases 
    post :update, { :administrator => {:aliases => "", :password => "", :confirm_password => "" }, :save_aliases => 1 }
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "index"
    rq = ActiveResource::HttpMock.requests.find {
	|r| r.method == :post && r.path == "/administrator.xml"
    }
    assert rq #commit request send
    assert rq.body
    hash = Hash.from_xml(rq.body)["administrator"]
    assert_equal hash["aliases"], "NONE"
    assert_nil hash["password"]
  end

  def test_passwords_do_not_match
    post :update, { :administrator => {:aliases => "", :password => "a", :confirm_password => "b" } }
    assert flash[:error]
    assert_equal flash[:error], "Passwords do not match."
    assert_response :redirect
    assert_redirected_to :controller => "administrator", :action => "index"
  end

  def test_wrong_alias
    post :update, { :administrator => {:aliases => "@wrong-email", :password => "a", :confirm_password => "b" } }
    assert flash[:error]
    assert_equal flash[:error], "Enter a valid e-mail address."
    assert_response :redirect
    assert_redirected_to :controller => "administrator", :action => "index"
  end

  def test_commit_with_aliases_wizard # goes to next step without warning, because mail config should follow
    Basesystem.stubs(:installed?).returns(true)
    session[:wizard_current] = "administrator"
    session[:wizard_steps] = "administrator,mail"
    post :update, { :administrator => {:aliases => "aa@bb.com", :password => "", :confirm_password => "" } }
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "nextstep"
  end

  def test_commit_with_mail_warning # should warn that there's no mail config
    post :update, { :administrator => {:aliases => "aa@bb.com", :password => "", :confirm_password => "" } }
    assert_response :redirect
    assert flash[:warning]
    assert_redirected_to :controller => "controlpanel", :action => "index"
  end

  # something failed in backend while saving
  def test_commit_failure
    response_admin_failure = IO.read(File.join(File.dirname(__FILE__),"..","fixtures","failed.xml"))
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.administrator" => "/administrator"
      mock.permissions "org.opensuse.yast.modules.yapi.administrator", { :read => true, :write => true }
      mock.get   "/administrator.xml", header, @response_admin, 200
      mock.post  "/administrator.xml", header, response_admin_failure, 500
    end
    ret = post :update, { :administrator => {:aliases => "", :password => "a", :confirm_password => "a" } }
    assert flash[:error]
    assert_equal flash[:error], "Error while saving administrator settings: error while saving aliases"
  end
  
end
