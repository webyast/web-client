# Generated by ruby-webyast-0.1 Selenium formatter
# Date: Wed Jul 22 2009 12:56:22 GMT+0200 (CEST)

require "selenium/test_case"

class Login_test_new2 < Selenium::TestCase
  
  def test_login_test_credentials
    @selenium.open "/hosts"
    @selenium.click "link=localhost"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_element_present("login")
    assert @selenium.is_element_present("password")
  end

  
  def test_login_test_services_list
    @selenium.open "/"
    assert @selenium.is_element_present("//div[@class='services-list']")
  end

  
  def test_login_test_guest_login
    @selenium.open "/hosts?error=nohostid"
    @selenium.click "link=localhost"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "login", "webyast_guest"
    @selenium.type "password", "test"
    @selenium.click "login_button"
    @selenium.wait_for_page_to_load "30000"
    assert !@selenium.is_element_present("Login incorrect")
    @selenium.click "link=Logout"
    @selenium.wait_for_page_to_load "30000"
    assert @selenium.is_text_present("You have been logged out")
  end


end
