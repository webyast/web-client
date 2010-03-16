require File.dirname(__FILE__) + '/../test_helper'
require 'mocha'

class LangController < ApplicationController
end

class LangControllerTest < ActionController::TestCase

  def setup
    @controller = LangController.new
  end

  def test_known_lang
    @controller.locale.stubs(:language).returns("es")
    assert_equal "es",@controller.current_locale
  end

  def test_unsuported_lang
    @controller.locale.stubs(:language).returns("af") #af is not supported now
    assert_equal "en_US",@controller.current_locale
  end

  def test_browser_lang
    @controller.locale.stubs(:language).returns("zh-cn")
    assert_equal "zh_CN",@controller.current_locale
  end

end
