rails_parent = ENV["RAILS_PARENT"]
unless rails_parent
  default_parent = "../../webclient"
  if File.directory?(default_parent)
     $stderr.puts "Taking #{default_parent} for RAILS_PARENT"
     rails_parent = default_parent
  else
     $stderr.puts "Please set RAILS_PARENT environment"
     exit
  end
end
# first config rails
require File.expand_path(rails_parent + "/config/environment")
# then enable testing, this will get the routing right
ENV["RAILS_ENV"] = "test"

require 'rubygems'
require 'active_support'
require 'active_support/test_case'
