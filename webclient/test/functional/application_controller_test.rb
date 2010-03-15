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
end
