#--
# Copyright (c) 2009-2010 Novell, Inc.
# 
# All Rights Reserved.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
# 
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#++

require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class MailControllerTest < ActionController::TestCase

  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    MailController.any_instance.stubs(:login_required)
    @request		= ActionController::TestRequest.new
    @response_mail	= fixture("mail-empty.xml")
    response_admin	= fixture("administrator-aliases.xml")
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.administrator" => "/administrator", :"org.opensuse.yast.modules.yapi.mailsettings" => "/mail"
      mock.permissions "org.opensuse.yast.modules.yapi.mailsettings", { :read => true, :write => true }
      mock.get   "/mail.xml", header, @response_mail, 200
      mock.get   "/administrator.xml", header, response_admin, 200
      mock.post  "/mail.xml", header, @response_mail, 200
    end
  end

  def test_index
    get :index
    assert_response :success
    assert_valid_markup
    assert assigns(:mail)
  end

  def test_commit
    post :update, { :mail => {
	:smtp_server			=> "smtp.server.com",
	:transport_layer_security	=> "no",
	:user				=> "",
	:password			=> "",
	:confirm_password		=> "",
	:test_mail_address		=> ""
      }
    }
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "index"
  end

  def test_commit_passwords_do_not_match
    post :update, { :mail => {
	:smtp_server			=> "",
	:transport_layer_security	=> "no",
	:user				=> "hh",
	:password			=> "a",
	:confirm_password		=> "b",
	:test_mail_address		=> ""
     }
    }
    assert_response :redirect
    assert flash[:error]
    assert_redirected_to :controller => "mail", :action => "index"
  end

  # smtp server empty, but admin forwarder set: show flash warning
  def test_commit_empty_server_forwaders
    post :update, { :mail => {
	:smtp_server			=> "",
	:transport_layer_security	=> "no",
	:user				=> "",
	:password			=> "",
	:confirm_password		=> "",
	:test_mail_address		=> ""
      }
    }
    assert_response :redirect
    assert flash[:warning]
    assert_redirected_to :controller => "controlpanel", :action => "index"
  end

  # smtp server empty, admin will be in the sequence: no warning
  def test_commit_empty_server_wizard
    Basesystem.stubs(:installed?).returns(true)
    session[:wizard_current] = "mail"
    session[:wizard_steps] = "mail,administrator"
    post :update, { :mail => {
	:smtp_server			=> "",
	:transport_layer_security	=> "no",
	:user				=> "",
	:password			=> "",
	:confirm_password		=> "",
	:test_mail_address		=> ""
      }
    }
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "nextstep"
  end

  def test_commit_failure
    response_mail_failed = fixture("mail-failed.xml")
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.mailsettings" => "/mail"
      mock.permissions "org.opensuse.yast.modules.yapi.mailsettings", { :read => true, :write => true }
      mock.get   "/mail.xml", header, @response_mail, 200
      mock.post  "/mail.xml", header, response_mail_failed, 500
    end

    post :update, { :mail => {
	:smtp_server			=> "",
	:transport_layer_security	=> "no",
	:user				=> "",
	:password			=> "",
	:confirm_password		=> "",
	:test_mail_address		=> ""
      }
    }
    assert_response :redirect
    assert flash[:error]
    assert_redirected_to :controller => "mail", :action => "index"
  end
  
end
