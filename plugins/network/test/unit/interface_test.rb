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

class NetworkControllerTest < ActiveSupport::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    # stub what the REST is supposed to return
    response_ifcs = fixture "ifcs.xml"
    response_eth1 = fixture "ifc.xml"

    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      # this is inadequate, :singular is per resource,
      # and does NOT depend on :policy
      # see yast-rest-service/plugins/network/config/resources/*
      mock.resources({:"org.opensuse.yast.modules.yapi.network.interfaces" => "/network/interfaces"},
          { :policy => "org.opensuse.yast.modules.yapi.network"})
      mock.permissions "org.opensuse.yast.modules.yapi.network", { :read => true, :write => true }
      mock.get  "/network/interfaces.xml", header, response_ifcs, 200
      mock.get  "/network/interfaces/eth1.xml", header, response_eth1, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_find_all
    res = Interface.find :all
    assert res
  end

end
