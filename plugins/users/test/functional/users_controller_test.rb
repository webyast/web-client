require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'yast_mock'
require 'mocha'

class UsersControllerTest < ActionController::TestCase

  def setup
    UsersController.any_instance.stubs(:login_required)
    @request = ActionController::TestRequest.new
#FIXME move to separate load fixture method
    response_users = IO.read(File.join(File.dirname(__FILE__),"..","fixtures","emptycn.xml"))
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.users" => "/users"
      mock.permissions "org.opensuse.yast.modules.yapi.users", { :read => true, :write => true }
      mock.get   "/users.xml", header, response_users, 200
    end
  end

  def test_empty_full_name
    get :index
    assert_response :success
    assert_valid_markup
    assert assigns(:users)
  end
  
end
