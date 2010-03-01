require File.dirname(__FILE__) + '/../../test_helper'

class HtmlHelperTest < ActiveSupport::TestCase
  include ViewHelpers::HtmlHelper

  # test jQuery selector name escaping
  def test_safe_id

    # test nil behavior
    assert_equal nil, safe_id(nil)

    # regexp for safe_id() result - only ASCII letters, numbers, '-' and '_'
    r = /^[-a-zA-Z0-9_]*$/

    # test empty input
    assert_match r, safe_id('')

    # test symbols
    assert_match r, safe_id('!@#$%^&*()_+}{":?><\'')

    # test some UTF-8 characters
    assert_match r, safe_id('ěščřžýáíéůúÁŠČŘÝÁÍÉŮÚ')

    # test plain ASCII
    assert_match r, safe_id('plain ASCII input')

  end

end
