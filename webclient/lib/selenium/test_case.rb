require 'rubygems'
gem 'selenium-client', '>=1.2.16'
require 'selenium'

# test-unit gem is need, it provides startup and shutdown
# methods which are not available in Test::Unit included in standard Ruby.
# see http://test-unit.rubyforge.org/test-unit/
# and http://test-unit.rubyforge.org/test-unit/classes/Test/Unit/TestCase.html
gem 'test-unit', '>=2.0.2'
require 'test/unit'

module Selenium
    class TestCase < Test::Unit::TestCase

	# store the selenium object to @selenium variable
	# this is a convenience method, Selenium IDE generates tests with @selenium calls
	def setup
	    @selenium = self.class.selenium
	end

	class << self
	    # start the browser, it's used by all tests
	    def startup
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
	    end

	    def shutdown
		@selenium.stop unless $selenium
	    end

	    def selenium
		return @selenium
	    end
	end
    end

end

# vim: ft=ruby
