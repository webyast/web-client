# To change this template, choose Tools | Templates
# and open the template in the editor.
require File.dirname(__FILE__) + '/../test_helper'

class PrivateRoutingTest < ActionController::TestCase
  test "plugin private routing" do
    searchdir = File.join(File.dirname(__FILE__),"..","..","..","plugins")
    Dir.foreach(searchdir) { |filename|
      unless filename[0].chr == "."
        assert !File.exist?(File.join(searchdir,filename,"config","routes.rb")), "Plugin #{filename} contains private routing"
      end
    }
  end
end
