#require File.dirname(__FILE__) + '/../test_helper'
require 'test_helper'
require 'sessions_controller'
require 'active_resource/http_mock'

# Re-raise errors caught by the controller.
class SessionsController; def rescue_action(e) raise e end; end

class SessionsControllerTest < ActionController::TestCase

  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

#  fixtures :accounts

  def setup
    @controller = SessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @login_granted = "<hash><login>granted</login></hash>"
    @login_denied = "<hash><login>denied</login></hash>"
    @logout_granted = "<hash><logout>Goodbye!</logout></hash>"
  end

  def test_should_login_and_redirect
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/login.xml", {}, @login_granted
    end
    post :create, :login => 'quentin', :password => 'test'
    assert session[:account_id]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/login.xml", {}, @login_denied
    end
    
    post :create, :login => 'quentin', :password => 'bad password'
    assert_nil session[:account_id]
    assert_response :success
  end
  

  def test_should_logout
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/logout.xml", {}, nil
    end

    login_as :quentin
    delete :destroy
    assert_nil session[:account_id]
    assert_response :redirect
  end

  def test_should_remember_me
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/login.xml", {}, @login_granted
    end

    post :create, :login => 'quentin', :password => 'test', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/login.xml", {}, @login_granted
    end

    post :create, :login => 'quentin', :password => 'test', :remember_me => "0"
    assert_nil @response.cookies["auth_token"]
  end
  
  def test_should_delete_token_on_logout
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/logout.xml"
    end

    login_as :quentin
    delete :destroy
    assert_equal @response.cookies["auth_token"], []
  end

  def test_should_login_with_cookie
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/login.xml", {}, @login_granted
    end

    accounts(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/login.xml", {}, @login_granted
    end

    accounts(:quentin).remember_me
    accounts(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/login.xml", {}, @login_granted
    end

    accounts(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(account)
      auth_token accounts(account).remember_token
    end
end
