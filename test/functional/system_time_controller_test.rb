require File.dirname(__FILE__) + '/../test_helper'
require 'system_time_controller'

# Re-raise errors caught by the controller.
class SystemTimeController; def rescue_action(e) raise e end; end

class SystemTimeControllerTest < Test::Unit::TestCase
  def setup
    @controller = SystemTimeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
