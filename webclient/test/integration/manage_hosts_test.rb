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
# main_controller defaults to localhost in appliances
#      get "/"
#      assert_response :redirect
#      follow_redirect!
      get "sessions/new"
      # now at session/new
      # we dont have a host yet
      assert_response :redirect
      follow_redirect!
      # now at hosts/index
      assert_template "hosts/index"
    end
end
