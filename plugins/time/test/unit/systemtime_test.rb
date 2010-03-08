require File.join(File.dirname(__FILE__),'..','test_helper')
require 'mocha'
require 'yast_mock'

class SystemtimeTest < ActiveSupport::TestCase
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
      mock.resources :"org.opensuse.yast.modules.yapi.time" => "/systemtime"
      mock.permissions "org.opensuse.yast.modules.yapi.time", { :read => true, :write => true }
      mock.get  "/systemtime.xml", header, response, 200
    end
    @systemtime = Systemtime.find :one
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_find_one
    assert @systemtime
    assert_equal "Europe/Prague",@systemtime.timezone
    assert_equal "12:18:00", @systemtime.time
    assert !@systemtime.utcstatus
    assert_equal "07/02/2009", @systemtime.date
    assert !@systemtime.timezones.empty?
  end

  def test_regions
    assert @systemtime.regions.include? "Europe"
  end

  def test_region_for_timezone
    assert_equal "Europe", @systemtime.region.name
  end

TEST_PARAMS = {
  :timezone => "Germany",
  :region => "Europe",
  :utc => "true",
  :currenttime => "02:04:08",
  :date => { :date  => "02/04/08"}
  }

  def test_loading
    @systemtime.load_time TEST_PARAMS
    assert_equal TEST_PARAMS[:currenttime], @systemtime.time
    assert_equal TEST_PARAMS[:date][:date], @systemtime.date
    @systemtime.clear_time
    assert_nil @systemtime.time
    assert_nil @systemtime.date
    @systemtime.load_timezone TEST_PARAMS
    assert @systemtime.utcstatus
    assert_equal "Europe/Berlin",@systemtime.timezone
  end

end
