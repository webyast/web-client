require File.join(File.dirname(__FILE__),'..','test_helper')
require 'mocha'
require 'yast_mock'

class NetworkControllerTest < ActiveSupport::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    # stub what the REST is supposed to return
    response = fixture "systemtime.xml"

    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      # this is inadequate, :singular is per resource,
      # and does NOT depend on :policy
      # see yast-rest-service/plugins/network/config/resources/*
      mock.resources :"org.opensuse.yast.modules.yapi.time" => "/systemtime"
      mock.permissions "org.opensuse.yast.modules.yapi.time", { :read => true, :write => true }
      mock.get  "/systemtime.xml", header, response, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_find_one
    res = Systemtime.find :one
    assert res
    assert_equal "Europe/Prague",res.timezone
    assert_equal "12:18:00", res.time
    assert !res.utcstatus
    assert_equal "07/02/2009", res.date
    assert !res.timezones.empty?
  end



end
