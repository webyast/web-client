require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'mocha'
require 'yast_mock'

class RolesControllerTest < ActionController::TestCase
  
  def setup
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

end
