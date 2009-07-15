
require 'selenium/test_case'

class LoginTest < Test::Unit::TestCase

  include Selenium::TestCase

  # check if the service selection is displayed at the main page
  def test_host_selection
    @selenium.open "/hosts"
    # is there the service list table?
    assert @selenium.is_element_present("services-list")
  end

  # check if the login page is displayed after clicking on the localhost:8080 target 
  def test_login_page
    @selenium.open "/hosts"
    @selenium.click "link=http://localhost:8080"
    @selenium.wait_for_page_to_load "30000"

    # is there the login and password entry?
    assert @selenium.is_element_present("password")
    assert @selenium.is_element_present("login")
  end

end

# vim: ft=ruby

