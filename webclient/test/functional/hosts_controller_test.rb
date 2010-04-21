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

require File.dirname(__FILE__) + '/../test_helper'

class HostsControllerTest < ActionController::TestCase
  fixtures :hosts

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:hosts)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_host
    assert_difference('Host.count') do
      post :create, :host => { :name => "new host", :url => "http://www.rubyonrails.org", :description => "Rails" }
    end

    # after creating we redirect to the full list
    assert_redirected_to hosts_path
  end

  def test_should_fail_create_host
    post :create, :host => { } # empty :host hash

    assert_redirected_to new_host_path
  end

  def test_should_fail_uri_validation
    post :create, :host => { :name => "bad uri", :url => "htx::/foo", :description => "Rails" }

    # after creation failure, ask for re-entering the values
    # FIXME
#    assert_redirected_to new_host_path
  end

  # re-create the first host of the fixture
  def test_host_uniqueness
    host = Host.find(:first)
    assert host
    post :create, :host => { :name => host.name, :url => host.url, :description => host.description }

    assert_redirected_to new_host_path
  end

  def test_should_show_host
    get :show, :id => hosts(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => hosts(:one).id
    assert_response :success
  end

  def test_should_update_host
    put :update, :id => hosts(:one).id, :host => { :name => "new host", :url => "http://www.rubyonrails.org", :description => "Rails" }
    # after creating we redirect to the full list
    assert_redirected_to hosts_path
  end

  def test_should_fail_update_host
    host = hosts(:one)
    # this should fail validation (name not unique)
    put :update, :id => hosts(:two).id, :host => { :name => host.name, :url => "http://www.rubyonrails.org", :description => "Rails" }
    # after creating we redirect to the edit dialog
    assert_redirected_to edit_host_path
  end

  def test_should_destroy_host
    assert_difference('Host.count', -1) do
      delete :destroy, :id => hosts(:one).id
    end

    assert_redirected_to hosts_path
  end
  
  # check the validate_uri ajax helper
  def test_validate_uri_true
    get :validate_uri, :host => { :url => "http://www.opensuse.org" }
    assert_equal @response.body, "true"
  end
  def test_validate_uri_false
    get :validate_uri, :host => { :url => "htx:/foo" }
    assert_equal @response.body, "false"
  end
end
