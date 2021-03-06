#--
# Webyast Webservice framework
#
# Copyright (C) 2009, 2010 Novell, Inc. 
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation. 
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details. 
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++

require 'selenium'

# test-unit gem is needed, it provides startup and shutdown
# methods which are not available in Test::Unit included in standard Ruby.
# see http://test-unit.rubyforge.org/test-unit/
# and http://test-unit.rubyforge.org/test-unit/classes/Test/Unit/TestCase.html
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
			"http://localhost:4568", 10000);
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
