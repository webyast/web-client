require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

require 'mocha'

# create a testing controller,
# defining an ApplicationControllerTest class doesn't work
class TestController < ApplicationController
  include Mocha::API

  def initialize
    # mock an ActiveResource object
    @obj = mock
    @obj.stubs(:errors).returns({"url"=>"blank", "keep_packages"=>"inclusion"})

    @mapping = {:url => 'URL', :keep_packages => 'Keep downloaded packages'}
  end

  def get_errors_with_mapping
    render :text => generate_error_messages(@obj, @mapping)
  end

  def get_errors_with_mapping_and_header
    render :text => generate_error_messages(@obj, @mapping, 'Custom error header')
  end

  def get_errors_without_mapping
    render :text => generate_error_messages(@obj)
  end

#for test protected method details
  def testing_details(msg,options={})
    details msg,options
  end
end


class TestControllerTest < ActionController::TestCase
  def test_generate_error_messages
    get :get_errors_with_mapping

    assert_false @response.body.blank?
    # check that mapped names are included
    assert @response.body.match /URL/
    assert @response.body.match /Keep downloaded packages/
  end

  def test_generate_error_messages_with_custom_header
    get :get_errors_with_mapping_and_header

    assert_false @response.body.blank?
    # check that mapped names are included
    assert @response.body.match /URL/
    assert @response.body.match /Keep downloaded packages/
    # check that the custom error message is used
    assert @response.body.match /Custom error header/
  end

  def test_generate_error_messages_without_mapping
    get :get_errors_without_mapping

    assert_false @response.body.blank?
    # check that raw attribute names are included
    assert @response.body.match /url/
    assert @response.body.match /keep_packages/
  end

  DETAILS_PREFIX = '<br><a href="#" onClick="$(\'.details\',this.parentNode).css(\'display\',\'block\');"><small>details</small></a><pre class="details" style="display:none">'
  DETAILS_SUFFIX = '</pre>'
  TEST_DETAILS_STR = "my wonderfull details <br>&nbsp;"
  TEST_DETAILS_RESULT = DETAILS_PREFIX+'my wonderfull details &lt;br&gt;&amp;nbsp;'+DETAILS_SUFFIX
  def test_details
    controller = TestController.new
    assert_equal (DETAILS_PREFIX+"lest"+DETAILS_SUFFIX).gsub(/\s/,''), controller.testing_details("lest").gsub(/\s/,'')
    assert_equal TEST_DETAILS_RESULT.gsub(/\s/,''), controller.testing_details(TEST_DETAILS_STR).gsub(/\s/,'') #test if result is expected except whitespace (which is ignored in html)
  end
end