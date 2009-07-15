require "rubygems"
gem "selenium-client", ">=1.2.16"

require "selenium"
require "test/unit"

module Selenium

    module TestCase

	def setup
	    @verification_errors = []

	    if $selenium
		@selenium = $selenium
	    else
		# Start Firefox browser by default (supportred browsers: *firefox2,
		# *firefox3, *opera, *konqueror *chrome)
		# specify the exact path to the binary (/usr/bin/firefox is a script,
		# Selenium server cannot correctly close the browser if it is started via the script)
		firefox = (File.exists? "/usr/lib64/firefox/firefox") ? "/usr/lib64/firefox/firefox" :
		    "/usr/lib/firefox/firefox"

		@selenium = Selenium::SeleniumDriver.new("localhost", 4444, "*firefox #{firefox}",
		    "http://localhost:3000", 10000);
		@selenium.start
	    end

	    @selenium.set_context("test_login")
	end

	def teardown
	    @selenium.stop unless $selenium
	    assert_equal [], @verification_errors
	end
    end

end
