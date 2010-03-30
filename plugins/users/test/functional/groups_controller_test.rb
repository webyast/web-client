require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'yast_mock'
require 'mocha'

class GroupsControllerTest < ActionController::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    GroupsController.any_instance.stubs(:login_required)
    # stub what the REST is supposed to return
    response_group_users  = fixture "groups/users.xml"
    response_index  = fixture "groups/index.xml"
    response_users  = fixture "users/users.xml"


#FIXME move to separate load fixture method
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.groups" => "/groups", "org.opensuse.yast.modules.yapi.users" => "/users"
      mock.permissions "org.opensuse.yast.modules.yapi.groups", { :read => true, :write => true }
      mock.get   "/groups.xml", header, response_index, 200
      mock.get   "/groups/users.xml", header, response_group_users, 200
      mock.delete   "/groups/users.xml", header, nil, 200
      mock.get	 "/users.xml", header, response_users, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_groups_index
    get :index
    assert_response :success
    assert_valid_markup
    assert assigns(:groups)
  end

  def test_edit_group
    get :edit, {:id => "users"}
    assert_response :success
    assert_valid_markup
    assert assigns(:group)
  end

  def test_delete_group
    post :destroy, {:id => "users"}
    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :index
    assert_valid_markup
    assert_false flash.empty?
  end

  def test_rename_group
    post :update, {"group" => {"cn"=>"new_name", "old_cn" => "users"} }
    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :index
    assert_valid_markup
    assert_false flash.empty?
  end
  
end
