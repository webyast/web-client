#--
# Webyast Webservice framework
#
# Copyright (C) 2009, 2010 Novell, Inc. 
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation. 
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details. 
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++

require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
require 'sessions_controller'
class SessionsController; def rescue_action(e) raise e end; end

# test the web client part of the login, which
# talks to a remote rest service to get the authentication
# token
class SessionsControllerTest < ActionController::TestCase

  fixtures :accounts, :hosts

  def setup
    @login_granted = "<hash><login>granted</login></hash>"
    @login_denied = "<hash><login>denied</login></hash>"
    @logout_granted = "<hash><logout>Goodbye!</logout></hash>"

    @host = Host.find(1)
    current_account = Account.new
    auth_token = "abcdef"
    Account.stubs(:authenticate).with("quentin","test",@host.url,"0.0.0.0").returns([current_account, auth_token])
    Account.stubs(:authenticate).with("quentin","bad password",@host.url, "0.0.0.0").returns([nil,nil])
    Account.stubs(:authenticate).with("quentin","bad host",@host.url, "0.0.0.0").raises(Errno::ECONNREFUSED)
    YaST::ServiceResource::Session.site = @host.url
    ActiveResource::Base.site = @host.url
  end

  # new without any parameters should redirect to hosts
  def test_new
    get :new
    assert_redirected_to :controller => :hosts, :error => "nohostid"
  end

  # new with :hostname empty
  def test_new_with_empty_hostid
    get :new, :hostid => nil
    assert_redirected_to :controller => :hosts, :error => "nohostid"
  end

  # new with hostname, must show login
  def test_new_shows_login
    get :new, :hostid => @host.id
    assert_select "form input", 4  # hostid, username, password, submit
  end

  # without a service host to to login, we should
  # be redirected to web service choosing...
  def test_create_should_redirect_to_select_host
    post :create
    assert flash[:warning]
    assert_redirected_to :action => :new
  end

  # create with blank password
  def test_create_with_blank_password
    post :create, :password => "", :hostid => @host.id
    assert flash[:warning]
    assert_redirected_to :action => :new, :hostid => @host.id
  end

  def test_create_successful_login
    ActiveResource::HttpMock.respond_to do |mock|
      mock.post "/login.xml", {}, @login_granted
    end
    post :create, :hostid => @host.id,
         :login => 'quentin', :password => 'test'
    assert_nil flash[:warning]
    assert_nil flash[:error]
    assert session[:auth_token]
    assert session[:user]
    assert session[:host]
    assert_redirected_to "/"
  end

  def test_create_with_authentication_failure
    post :create, :login => 'quentin', :password => 'bad password', :hostid => @host.id
    assert_nil session[:account_id]
    assert flash[:warning]
    assert_nil flash[:error]
    # we should be at the login form again
    assert_redirected_to :controller => :sessions, :action => :new, :hostid => @host.id
  end
  
  def test_create_with_connection_refused
    post :create, :login => 'quentin', :password => 'bad host', :hostid => @host.id
    assert_nil session[:account_id]
    assert_nil flash[:warning]
    # we should be at the hosts list againn
    assert_redirected_to :controller => :hosts, :hostid => @host.id, :error => "econnrefused"
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
