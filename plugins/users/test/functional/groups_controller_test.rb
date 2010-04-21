#--
# Copyright (c) 2009-2010 Novell, Inc.
# 
# All Rights Reserved.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
# 
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#++

require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class GroupsControllerTest < ActionController::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    GroupsController.any_instance.stubs(:login_required)
    # stub what the REST is supposed to return
    response_group_users  = fixture "groups/users.xml"
    response_index  = fixture "groups/index.xml"
    response_users  = fixture "users/users.xml"


#FIXME move to separate load fixture method
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.groups" => "/groups", "org.opensuse.yast.modules.yapi.users" => "/users"
      mock.permissions "org.opensuse.yast.modules.yapi.groups", { :read => true, :write => true }
      mock.get   "/groups.xml", header, response_index, 200
      mock.get   "/groups/users.xml", header, response_group_users, 200
      mock.delete   "/groups/users.xml", header, nil, 200
      mock.put   "/groups/users.xml", header, nil, 200
      mock.get	 "/users.xml", header, response_users, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_groups_index
    get :index
    assert_response :success
#   commented because it freezes test
#    assert_valid_markup
    assert assigns(:groups)
  end

  def test_edit_group
    get :edit, {:id => "users"}
    assert_response :success
    assert_valid_markup
    assert assigns(:group)
  end

  def test_delete_group
    post :destroy, {:id => "users"}
    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :index
    assert_valid_markup
    assert_false flash.empty?
  end

  def test_rename_group
    post :update, {"group" => {"cn"=>"new_name", "old_cn" => "users"} }
    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :index
    assert_valid_markup
    assert_false flash.empty?
  end
  
end
