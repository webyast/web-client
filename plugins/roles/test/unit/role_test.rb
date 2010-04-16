require File.join(File.dirname(__FILE__),'..','test_helper')

class RoleTest < ActiveSupport::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_find
    response_roles = fixture "roles.xml"
    response_role = fixture "test2.xml"
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
    end
   assert Role.find :all
   assert Role.find :test2
  end
end
