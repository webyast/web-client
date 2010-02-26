require File.dirname(__FILE__) + '/../../test_helper'

class HtmlHelperTest < ActiveSupport::TestCase
  include ViewHelpers::HtmlHelper

  # test jQuery selector name escaping
  def test_jquery_selector_escaping
    # all problematic characters should be prefixed by double back slash
    assert_equal "\\\\@\\\\#\\\\;\\\\&\\\\,\\\\.\\\\+\\\\*\\\\~\\\\'\\\\:\\\\\"\\\\!\\\\^\\\\$\\\\[\\\\]\\\\(\\\\)\\\\=\\\\>\\\\|\\\\/\\\\%\\\\ ",
      escape_jquery_selector('@#;&,.+*~\':"!^$[]()=>|/% ')

    # ASCII characters must not be changed
    assert_equal "ASDFG123asdfg123", escape_jquery_selector("ASDFG123asdfg123")

    # when mixed escape only problematic symbols
    assert_equal "asdf\\\\(\\\\)\\\\+-123", escape_jquery_selector("asdf()+-123")
  end

end
