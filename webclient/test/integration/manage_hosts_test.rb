#
# test/integration/manage_hosts_test.rb
#
#
require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class ManageHostsTest < ActionController::IntegrationTest
  fixtures :accounts

  # add a new host
  test "add a new host" do
    list_hosts
    get "hosts/new"
    assert_response :success
    
  end
  
  # add a new host with a bad url
  test "add a new host with a bad url" do
    get "/"
    assert_response :redirect
  end
  
  
  private
    def list_hosts
      get "/"
      assert_response :redirect
      follow_redirect!
      # now at session/new
      # we dont have a host yet
      assert_response :redirect
      follow_redirect!
      # now at hosts/index
    end
end
