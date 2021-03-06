#--
# Copyright (c) 2009-2010 Novell, Inc.
# 
# All Rights Reserved.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
# 
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#++

# Generated by ruby-webyast-0.1 Selenium formatter
# Date: Fri Aug 21 2009 14:25:52 GMT+0200 (CEST)

if File.exist?(File.expand_path(File.dirname(__FILE__) + "/../../config/rails_parent.rb"))
  require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
  require File.expand_path( File.join("lib","selenium","test_case"), RailsParent.parent )
else
  require "selenium/test_case"
end
class Systemtime_test < Selenium::TestCase
  
  def test_systemtime_test_login
    @selenium.open "/systemtime"
    @selenium.click "link=dummy-host"
    @selenium.wait_for_page_to_load "30000"
    @selenium.type "login", "webyast"
    @selenium.type "password", "test"
    @selenium.click "login_button"
    @selenium.wait_for_page_to_load "30000"
    assert !@selenium.is_element_present("Enter login credentials")
  end

  
  def test_systemtime_test_lookat
    @selenium.open "/systemtime"
    assert @selenium.is_element_present("currenttime")
    assert @selenium.is_element_present("utc")
    @selenium.click "date_date"
    assert @selenium.is_element_present("xpath=//div[@id=\"ui-datepicker-div\"]")
    assert @selenium.is_element_present("css=div#ui-datepicker-div")
    @selenium.click "link=21"
    @selenium.click "//a[contains(@href, '/logout')]"
    @selenium.wait_for_page_to_load "30000"
  end


end
