require File.join(File.dirname(__FILE__),'..','test_helper')
require 'mocha'
require 'yast_mock'

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
end
