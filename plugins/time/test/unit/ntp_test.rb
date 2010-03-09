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
    @response = fixture "ntp.xml"

    ActiveResource::HttpMock.set_authentication
    @header = ActiveResource::HttpMock.authentication_header
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources :"org.opensuse.yast.modules.yapi.ntp" => "/ntp"
      mock.permissions "org.opensuse.yast.modules.yapi.ntp", { :available => true, :synchronize => true }
      mock.permissions "org.opensuse.yast.modules.yapi.services", { :execute => true, :read => true } #service is needed restart service
      mock.get  "/ntp.xml", @header, @response, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_available
    assert Ntp.available?
  end

  def test_available_not_perm
    Ntp.instance_variable_set(:@permissions,nil) #reset permissions cache
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources :"org.opensuse.yast.modules.yapi.ntp" => "/ntp"
      mock.permissions "org.opensuse.yast.modules.yapi.ntp", { :available => true, :synchronize => false }
      mock.get  "/ntp.xml", @header, @response, 200
    end
    assert !Ntp.available?
  end

  def test_available_not_available
    response = fixture "ntp_unavailable.xml"
    Ntp.instance_variable_set(:@permissions,nil) #reset permissions cache
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources :"org.opensuse.yast.modules.yapi.ntp" => "/ntp"
      mock.permissions "org.opensuse.yast.modules.yapi.ntp", { :available => true, :synchronize => true }
      mock.get  "/ntp.xml", @header, response, 200
    end
    assert !Ntp.available?
  end

  def test_available_failed
    response = fixture "ntp_unavailable.xml"
    Ntp.instance_variable_set(:@permissions,nil) #reset permissions cache
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources :"org.opensuse.yast.modules.yapi.ntp" => "/ntp"
      mock.permissions "org.opensuse.yast.modules.yapi.ntp", { :available => true, :synchronize => true }
      mock.get  "/ntp.xml", @header, "plugin missing", 404
    end
    assert !Ntp.available?
  end
end
