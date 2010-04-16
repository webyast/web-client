require File.dirname(__FILE__) + '/../test_helper'

class ControlPanelConfigTest < ActiveSupport::TestCase

  def test_read
    test_result = {
      "patches_status_timeout" => 86400,
      "display_patches_status" => true,
      "system_status_timeout" => 60,
      "display_system_status" => true
    }

    YAML.stubs(:load_file).returns(test_result)

    assert_nothing_raised do
      # read an existing value
      assert_equal 86400, ControlPanelConfig.read('patches_status_timeout')

      # read missing value
      assert_nil ControlPanelConfig.read 'missing_value'

      # read missing value with default
      assert_equal 42, ControlPanelConfig.read('missing_value', 42)

      # read a complete config
      assert_equal test_result, ControlPanelConfig.read


      # test missing file (reading throws an exception)
      excpt = Errno::ENOENT.new '/etc/webyast/control_panel.yml'
      YAML.stubs(:load_file).raises(excpt)

      # read a value
      assert_nil ControlPanelConfig.read 'patches_status_timeout'

      # read a value with default
      assert_equal 42, ControlPanelConfig.read('patches_status_timeout', 42)

      # read complete config
      assert_nil ControlPanelConfig.read
    end

  end

end
