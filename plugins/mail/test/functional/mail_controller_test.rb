require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'yast_mock'
require 'mocha'

class MailControllerTest < ActionController::TestCase

  def setup
    MailController.any_instance.stubs(:login_required)
    @request = ActionController::TestRequest.new
    response_mail= IO.read(File.join(File.dirname(__FILE__),"..","fixtures","mail-empty.xml"))
    response_admin= IO.read(File.join(File.dirname(__FILE__),"..","fixtures","administrator-aliases.xml"))
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.administrator" => "/administrator", :"org.opensuse.yast.modules.yapi.mailsettings" => "/mail"
      mock.permissions "org.opensuse.yast.modules.yapi.mailsettings", { :read => true, :write => true }
      mock.get   "/mail.xml", header, response_mail, 200
      mock.get   "/administrator.xml", header, response_admin, 200
      mock.post  "/mail.xml", header, response_mail, 200
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
	:confirm_password		=> "" }
    }
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "index"
  end

  # smtp server empty, but admin forwarder set: show flash warning
  def test_commit_empty_server_forwaders
    post :update, { :mail => {
	:smtp_server			=> "",
	:transport_layer_security	=> "no",
	:user				=> "",
	:password			=> "",
	:confirm_password		=> "" }
    }
    assert_response :redirect
    assert flash[:warning]
    assert_redirected_to :controller => "controlpanel", :action => "index"
  end

  # smtp server empty, admin will be in the sequence: no warning
  def test_commit_empty_server_wizard
    session[:wizard_current] = "mail"
    session[:wizard_steps] = "mail,administrator"
    post :update, { :mail => {
	:smtp_server			=> "",
	:transport_layer_security	=> "no",
	:user				=> "",
	:password			=> "",
	:confirm_password		=> "" }
    }
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "nextstep"
  end

  
end
