require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class RolesControllerTest < ActionController::TestCase
  def users_fixture
    git_loc = File.join(File.dirname(__FILE__),"..","..","..","users","test","fixtures","users","users.xml")
    if File.exists? git_loc
      IO.read git_loc
    else
      IO.read File.join( RailsParent.parent, "vendor", "plugins", "users", "test", "fixtures", "users","users.xml" )
    end
  end

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
      mock.resources({:"org.opensuse.yast.roles" => "/roles", :'org.opensuse.yast.modules.yapi.users' => "/users"})
      mock.permissions "org.opensuse.yast.modules.yapi.network", { :read => true, :write => true }
      mock.get  "/roles.xml", header, response_roles, 200
      mock.get  "/roles/test2.xml", header, response_role, 200
      mock.get  "/permissions.xml?with_description=1", ActiveResource::HttpMock.authentication_header_without_language, response_perm, 200
      mock.get "/users.xml", header, users_fixture, 200
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
