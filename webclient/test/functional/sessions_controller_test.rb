require File.dirname(__FILE__) + '/../test_helper'

require 'active_resource/http_mock'

# Re-raise errors caught by the controller.
require 'sessions_controller'
class SessionsController; def rescue_action(e) raise e end; end

# test the web client part of the login, which
# talks to a remote rest service to get the authentication
# token
class SessionsControllerTest < ActionController::TestCase

  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :accounts

  def setup
    @login_granted = "<hash><login>granted</login></hash>"
    @login_denied = "<hash><login>denied</login></hash>"
    @logout_granted = "<hash><logout>Goodbye!</logout></hash>"

    @hostname = "http://localhost:8000"
    YaST::ServiceResource::Session.site = @hostname
    ActiveResource::Base.site = @hostname
  end

  # new without any parameters should redirect to webservices
  def test_new
    get :new
    assert_redirected_to :controller => :webservices
  end

  # new with :hostname empty
  def test_new_with_empty_hostname
    get :new, :hostname => ""
    assert_redirected_to :controller => :webservices
    assert flash[:notice]
  end

  # new with hostname, must show login
  def test_new_shows_login
    get :new, :hostname => @hostname
    assert_select "form input", 2
    assert_select "title", "Login"
  end

  # without a service hostname to to login, we should
  # be redirected to web service choosing...
  def test_should_redirect_to_select_hostname
    get :new, :login => 'quentin', :password => 'test'
    assert_redirected_to :controller => :webservices
  end

  def test_should_login_and_redirect
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/login.xml", {}, @login_granted
    end
    post :create, :hostname => @hostname,
         :login => 'quentin', :password => 'test'
    # success ful login sends you to control panel
    # FIXME however login is not working in tests
    # assert_redirected_to :controller => :controlpanel
  end

  def test_should_fail_login_and_send_to_new
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/login.xml", {}, @login_denied
    end
    
    post :create, :login => 'quentin', :password => 'bad password'
    assert_nil session[:account_id]
    # we should be at the login form again
    assert_redirected_to :controller => :sessions, :action => :new
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
    # FIXME, not working
    #assert_not_nil @response.session[:auth_token]
  end

  def test_should_not_remember_me
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/login.xml", {}, @login_granted
    end

    post :create, :login => 'quentin', :password => 'test', :remember_me => "0"
    assert_nil @response.session[:auth_token]
  end
  
  def test_should_delete_token_on_logout
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/logout.xml", {}, @logout_granted
    end

    login_as :quentin
    delete :destroy
    assert_nil @response.cookies[:auth_token]
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
    @request.cookies[:auth_token] = auth_token('invalid_auth_token')
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
