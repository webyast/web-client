require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'mocha'
require 'yast_mock'

class RolesControllerTest < ActionController::TestCase
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end
  
  def setup
    RolesController.any_instance.stubs(:login_required)
    response_roles = fixture "roles.xml"
    response_role = fixture "test2.xml"
    response_perm = fixture "permissions.xml"
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      # this is inadequate, :singular is per resource,
      # and does NOT depend on :policy
      # see yast-rest-service/plugins/network/config/resources/*
      mock.resources({:"org.opensuse.yast.roles" => "/roles"})
      mock.permissions "org.opensuse.yast.modules.yapi.network", { :read => true, :write => true }
      mock.get  "/roles.xml", header, response_roles, 200
      mock.get  "/roles/test2.xml", header, response_role, 200
      mock.get  "/permissions.xml?with_description=1", header, response_perm, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_index
    get :index
    assert_response :success
    assert assigns :roles
  end

  def test_edit
    get :edit, :id => "test2" 
    assert_response :success
    assert assigns :role
    assert assigns :permissions
  end

end
