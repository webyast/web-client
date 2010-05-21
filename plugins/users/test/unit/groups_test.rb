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

require File.join(File.dirname(__FILE__),'..','test_helper')

class GroupsControllerTest < ActiveSupport::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    # stub what the REST is supposed to return
    response_g_users = fixture "groups/users.xml"
    response_groups = fixture "groups/groups.xml"

    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      # this is inadequate, :singular is per resource,
      # and does NOT depend on :policy
      # see yast-rest-service/plugins/network/config/resources/*
      mock.resources({ :"org.opensuse.yast.modules.yapi.users" => "/users",
                       :"org.opensuse.yast.modules.yapi.groups" => "/groups" },
                     { :policy => "org.opensuse.yast.modules.yapi.users" } )
      mock.permissions( "org.opensuse.yast.modules.yapi.users", 
                        { :userget  => true, :usersget  => true, :useradd  => true, :usermodify  => true, :userdelete  => true,
                          :groupget => true, :groupsget => true, :groupadd => true, :groupmodify => true, :groupdelete => true } )
      mock.get  "/groups/users.xml", header, response_g_users, 200
      mock.get  "/groups.xml", header, response_groups, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_find_all
    res = Group.find :all
    assert res
    assert_instance_of(Array, res)
    assert_not_nil res[0].cn
    assert_not_nil res[0].old_cn
    assert_not_nil res[0].gid
    assert_not_nil res[0].group_type
    assert_not_nil res[0].default_members
    assert_not_nil res[0].members
  end

  def test_find_users
    res = Group.find "users"
    assert res
    assert_not_nil res.cn
    assert_not_nil res.old_cn
    assert_not_nil res.gid
    assert_not_nil res.group_type
    assert_not_nil res.default_members
    assert_not_nil res.members
  end
end
