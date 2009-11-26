require File.dirname(__FILE__) + '/../test_helper'
require 'mocha'

class LangController < ApplicationController
end

class LangControllerTest < ActionController::TestCase
  SUPPORTED_LANG = [ "en_US", "en_GB", "cs_CZ", "de_DE" ]

  def setup
    @controller = LangController.new
    I18n.supported_locales= SUPPORTED_LANG
  end

  def test_known_lang
    @controller.locale.stubs(:language).returns("cs_CZ")
    assert_equal "cs_CZ",@controller.current_locale
  end

  def test_unsuported_lang
    @controller.locale.stubs(:language).returns("pt_BR")
    assert_equal "en_US",@controller.current_locale
  end

  def test_browser_lang
    @controller.locale.stubs(:language).returns("en-gb")
    assert_equal "en_GB",@controller.current_locale
  end

end
  
