require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'yast_mock'
require 'mocha'

class UsersControllerTest < ActionController::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    UsersController.any_instance.stubs(:login_required)
    # stub what the REST is supposed to return
    response_index  = fixture "users/users.xml"
    response_tester = fixture "users/tester.xml"
    response_users  = fixture "users/emptycn.xml"
    response_groups  = fixture "users/groups.xml"


#FIXME move to separate load fixture method
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.users" => "/users", :"org.opensuse.yast.modules.yapi.groups" => "/groups"
      mock.permissions "org.opensuse.yast.modules.yapi.users", { :read => true, :write => true }
      mock.get   "/users.xml", header, response_index, 200
      mock.get   "/users/tester.xml", header, response_tester, 200
      mock.permissions "org.opensuse.yast.modules.yapi.groups", { :read => true, :write => true }
      mock.get   "/groups/.xml", header, response_groups, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_empty_full_name
    get :index
    assert_response :success
    assert_valid_markup
    assert assigns(:users)
  end

  def test_users_index
    get :index
    assert_response :success
    assert_valid_markup
    assert assigns(:users)
    assert_select 'td#login', "tester"
    assert_select 'td#fullname', "Tester Testerovic"
    assert_select 'td#login', "tester"
    assert_select 'td#fullname', 2
  end

  def test_edit_user
    get :edit, {:id => "tester"}
    assert_response :success
    assert_valid_markup
    assert assigns(:user)
    assert_select 'input#user_id[value=tester]' # fallback for uid
    assert_select 'input#user_uid[value=tester]'
    assert_select 'input#user_cn[value=Tester Testerovic]'
    assert_select 'input#user_grp_string[value=uucp,games,messagebus]'
    assert_select 'input#user_groupname[value=users]'
  end
  
end
