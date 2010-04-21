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

class UsersControllerTest < ActiveSupport::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    # stub what the REST is supposed to return
    response_index = fixture "users/users.xml"
    response_tester = fixture "users/tester.xml"

    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      # this is inadequate, :singular is per resource,
      # and does NOT depend on :policy
      # see yast-rest-service/plugins/network/config/resources/*
      mock.resources({:"org.opensuse.yast.modules.yapi.users" => "/users"},
          { :policy => "org.opensuse.yast.modules.yapi.users"})
      mock.permissions "org.opensuse.yast.modules.yapi.users", { :read => true, :write => true }
      mock.get  "/users.xml", header, response_index, 200
      mock.get  "/users/tester.xml", header, response_tester, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_find_all
    res = User.find :all
    assert res
  end

  def test_find_tester
    res = User.find :tester
    assert res
  end

end
