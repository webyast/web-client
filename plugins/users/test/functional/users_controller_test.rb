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

class UsersControllerTest < ActionController::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    UsersController.any_instance.stubs(:login_required)
    # stub what the REST is supposed to return
    response_index  = fixture "users/users.xml"
    response_tester = fixture "users/tester.xml"
    response_users  = fixture "users/emptycn.xml"
    response_groups  = fixture "groups/groups.xml"
    response_roles  = fixture "roles.xml"


#FIXME move to separate load fixture method
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.users" => "/users", :"org.opensuse.yast.modules.yapi.groups" => "/groups", :"org.opensuse.yast.roles" => "/roles"
      mock.permissions "org.opensuse.yast.modules.yapi.users", { :read => true, :write => true }
      mock.get   "/users.xml", header, response_index, 200
      mock.get   "/users/tester.xml", header, response_tester, 200
      mock.put   "/users/tester.xml", header, nil, 200
      mock.permissions "org.opensuse.yast.modules.yapi.groups", { :groupsget => true }
      mock.get   "/groups.xml", header, response_groups, 200
      mock.get   "/roles.xml", header, response_roles, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_empty_full_name
    get :index
    assert_response :success
    assert_valid_markup
    assert assigns(:users)
  end

  def test_users_index
    get :index
    assert_response :success
    assert_valid_markup
    assert assigns(:users)
#    assert_select '#all_grps_string[value="ntp,utmp,video,disk,nobody,polkituser,mail,nogroup,lp,pulse,news,www,pulse-rt,uucp,at,kmem,pulse-access,shadow,maildrop,ntadmin,root,suse-ncc,dialout,ftp,bin,gdm,audio,games,postfix,man,users,messagebus,lighttpd,daemon,xok,haldaemon,yastws,floppy,cdrom,sys,trusted,wheel,uuidd,console,public,modem,sshd,sfcb,tty"]'
  end

  def test_users_index_no_groupsget_permission
    response_index  = fixture "users/users.xml"
    response_groups  = fixture "groups/groups.xml"
    response_roles  = fixture "roles.xml"
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.users" => "/users", :"org.opensuse.yast.modules.yapi.groups" => "/groups", :"org.opensuse.yast.roles" => "/roles"
      mock.permissions "org.opensuse.yast.modules.yapi.users", { :read => true, :write => true }
      mock.get   "/users.xml", header, response_index, 200
      mock.permissions "org.opensuse.yast.modules.yapi.groups", { :groupsget => false }
      mock.get   "/groups.xml", header, response_groups, 200
      mock.get   "/roles.xml", header, response_roles, 200
    end
    get :index
    assert_response :success
    assert_valid_markup
    assert assigns(:users)
    assert_select '#all_grps_string[value=""]'
  end

  def test_update_user
   post :update, {:user => { :id => "tester", :cn => "Tester Testerovic" }} 
    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :index
    assert_valid_markup
    assert_false flash.empty?
  end  

end
