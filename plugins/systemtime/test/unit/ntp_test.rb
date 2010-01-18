require File.join(File.dirname(__FILE__),'..','test_helper')
require 'mocha'
require 'yast_mock'

class NtpTest < ActiveSupport::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    # stub what the REST is supposed to return
    response = fixture "ntp.xml"

    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources :"org.opensuse.yast.modules.yapi.ntp" => "/ntp"
      mock.permissions "org.opensuse.yast.modules.yapi.ntp", { :available => true, :synchronize => true }
      mock.get  "/ntp.xml", header, response, 200
    end
    @ntp = Ntp.find :one
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_available
    assert @ntp.available?
  end

end
