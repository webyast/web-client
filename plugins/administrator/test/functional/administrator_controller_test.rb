require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'yast_mock'
require 'mocha'

class AdministratorControllerTest < ActionController::TestCase

  def setup
    AdministratorController.any_instance.stubs(:login_required)
    @request = ActionController::TestRequest.new
    response_admin= IO.read(File.join(File.dirname(__FILE__),"..","fixtures","empty.xml"))
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.administrator" => "/administrator"
      mock.permissions "org.opensuse.yast.modules.yapi.administrator", { :read => true, :write => true }
      mock.get   "/administrator.xml", header, response_admin, 200
      mock.post  "/administrator.xml", header, response_admin, 200
    end
  end

  def test_index
    get :index
    assert_response :success
    assert_valid_markup
    assert assigns(:administrator)
  end

  def test_commit_without_aliases
    post :update, { :administrator => {:aliases => "", :password => "a", :confirm_password => "a" } }
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "index"
  end

  def test_passwords_do_not_match
    post :update, { :administrator => {:aliases => "", :password => "a", :confirm_password => "b" } }
    assert flash[:error]
    assert_response :redirect
    assert_redirected_to :controller => "administrator", :action => "index"
  end

#  def test_commit_with_aliases FIXME fails on Basesystem.new.load_from_session...
#    post :update, { :administrator => {:aliases => "aa@bb.com", :password => "", :confirm_password => "" } }
#    assert_response :redirect
#    assert_redirected_to :controller => "controlpanel", :action => "index"
#  end

  
end
