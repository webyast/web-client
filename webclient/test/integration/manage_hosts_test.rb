#
# test/integration/manage_hosts_test.rb
#
#
require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class ManageHostsTest < ActionController::IntegrationTest
  fixtures :accounts

  # add a new host
  test "add a new host and submit" do
    list_hosts
    
    # push "add" button
    get "hosts/new"
    assert_response :success
    
    # enter form and push "create"
    post "hosts/create", "host[name]" => "localhost", "host[url]" => "http://localhost:81", "host[description]" => "This is a test"
    
    # create redirects to index
    assert_response :redirect
    follow_redirect!
    
#FIXME    assert flash[:notice]
    assert_template "hosts/index"    
  end
  
  # add a new host with a bad url
  test "add a new host with a bad url" do
    get "/"
    assert_response :redirect
    
    # push "add" button
    get "hosts/new"
    assert_response :success
    
    # enter form and push "create"
    post "hosts/create", "host[name]" => "localhost", "host[url]" => "foo", "host[description]" => "This has a bad url"
    
    # create redirects to new and reports error
    assert_response :redirect
    follow_redirect!
    
#FIXME    assert flash[:warning]
    assert_template "hosts/new"
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
      assert_template "hosts/index"
    end
end
