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
    response_index = fixture "users.xml"
    response_tester = fixture "tester.xml"

    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      # this is inadequate, :singular is per resource,
      # and does NOT depend on :policy
      # see yast-rest-service/plugins/network/config/resources/*
      mock.resources({:"org.opensuse.yast.modules.yapi.users" => "/users"},
          { :policy => "org.opensuse.yast.modules.yapi.users"})
      mock.permissions "org.opensuse.yast.modules.yapi.users", { :read => true, :write => true }
      mock.get  "/users.xml", header, response_index, 200
      mock.get  "/users/tester.xml", header, response_tester, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_find_all
    res = User.find :all
    assert res
  end

  def test_find_tester
    res = User.find :tester
    assert res
  end

end
