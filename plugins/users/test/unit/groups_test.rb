require File.join(File.dirname(__FILE__),'..','test_helper')
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'mocha'
require 'yast_mock'
class UsersControllerTest < ActiveSupport::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    # stub what the REST is supposed to return
    response_g_users = fixture "groups/users.xml"
    response_groups = fixture "groups/groups.xml"

    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      # this is inadequate, :singular is per resource,
      # and does NOT depend on :policy
      # see yast-rest-service/plugins/network/config/resources/*
      mock.resources({:"org.opensuse.yast.modules.yapi.groups" => "/groups"},
          { :policy => "org.opensuse.yast.modules.yapi.groups"})
      mock.permissions "org.opensuse.yast.modules.yapi.groups", { :read => true, :write => true }
      mock.get  "/groups/users.xml", header, response_g_users, 200
      mock.get  "/groups/.xml", header, response_groups, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_find_all
    res = Group.find :all
    assert res
    assert_instance_of(Array, res)
  end

  def test_find_tester
    res = Group.find :users
    assert res
  end
end
