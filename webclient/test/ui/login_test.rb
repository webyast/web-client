require "rubygems"
gem "selenium-client", ">=1.2.16"

require "selenium"
require "test/unit"

class LoginTest < Test::Unit::TestCase
  def setup
    @verification_errors = []
    if $selenium
      @selenium = $selenium
    else
      # Start Firefox browser by default (supportred browsers: *firefox2, *firefox3, *opera, *konqueror *chrome)
      # specify the exact path to the binary (/usr/bin/firefox is a script,
      # Selenium server cannot correctly close the browser if it is started via the script)
      firefox = (File.exists? "/usr/lib64/firefox/firefox") ? "/usr/lib64/firefox/firefox" : "/usr/lib/firefox/firefox"

      @selenium = Selenium::SeleniumDriver.new("localhost", 4444, "*firefox #{firefox}", "http://localhost:3000", 10000);
      @selenium.start
    end
    @selenium.set_context("test_login")
  end
  
  def teardown
    @selenium.stop unless $selenium
    assert_equal [], @verification_errors
  end


  # check if the service selection is displayed at the main page
  def test_host_selection
    @selenium.open "/webservices"
    # is there the service list table?
    assert @selenium.is_element_present("services-list")
  end

  # check if the login page is displayed after clicking on the localhost:8080 target 
  def test_login_page
    @selenium.open "/webservices"
    @selenium.click "link=exact:http://localhost:8080"
    @selenium.wait_for_page_to_load "30000"

    # is there the login and password entry?
    assert @selenium.is_element_present("password")
    assert @selenium.is_element_present("login")
  end
end
