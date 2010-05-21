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

class FirewallTest < ActiveSupport::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    # stub what the REST is supposed to return
    response = fixture "firewall.xml"

    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources :"org.opensuse.yast.modules.yapi.firewall" => "/firewall"
      mock.permissions "org.opensuse.yast.modules.yapi.firewall", { :read => true, :write => true }
      mock.get  "/firewall.xml", header, response, 200
    end
    @firewall = Firewall.find :one
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_find_one
    assert @firewall
    assert @firewall.use_firewall
    webyast_ui = @firewall.fw_services.find {|s| s.id =="service:webyast-ui"}
    assert webyast_ui
    assert webyast_ui.allowed
    assert_equal "WebYaST UI", webyast_ui.name
  end

end
