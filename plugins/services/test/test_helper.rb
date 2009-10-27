ENV["RAILS_ENV"] = "test"
require File.join(File.dirname(__FILE__), '..', 'config', 'rails_parent')
require File.expand_path( File.join("config","environment"), RailsParent.parent )

require 'active_support'
require 'active_support/test_case'
