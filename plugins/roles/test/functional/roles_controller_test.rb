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

class RolesControllerTest < ActionController::TestCase
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end
  
  def setup
    RolesController.any_instance.stubs(:login_required)
    response_roles = fixture "roles.xml"
    response_role = fixture "test2.xml"
    response_perm = fixture "permissions.xml"
    response_users = fixture "getent.xml"
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      # this is inadequate, :singular is per resource,
      # and does NOT depend on :policy
      # see yast-rest-service/plugins/network/config/resources/*
      mock.resources({:"org.opensuse.yast.roles" => "/roles", :'org.opensuse.yast.modules.yapi.users' => "/users"})
      mock.permissions "org.opensuse.yast.modules.yapi.roles", { :assign => true, :modify => true }
      mock.get  "/roles.xml", header, response_roles, 200
      mock.get  "/roles/test2.xml", header, response_role, 200
      mock.get  "/permissions.xml?with_description=1", ActiveResource::HttpMock.authentication_header_without_language, response_perm, 200
      mock.get "/users.xml?getent=1", header, response_users, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_index
    get :index
    assert_response :success
    assert assigns :roles
  end

end
