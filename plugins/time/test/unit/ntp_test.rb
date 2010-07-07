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

class NtpTest < ActiveSupport::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    # stub what the REST is supposed to return
    @response = fixture "ntp.xml"

    ActiveResource::HttpMock.set_authentication
    @header = ActiveResource::HttpMock.authentication_header
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources :"org.opensuse.yast.modules.yapi.ntp" => "/ntp", :"org.opensuse.yast.modules.yapi.services" => "/services"
      mock.permissions "org.opensuse.yast.modules.yapi.ntp", { :available => true, :synchronize => true }
      mock.permissions "org.opensuse.yast.modules.yapi.services", { :execute => true, :read => true } #service is needed restart service
      mock.get  "/ntp.xml", @header, @response, 200
    end
    ResourceCache.instance.send(:permissions=,[]) #reset cache
    ResourceCache.instance.send(:resources=,[]) #reset cache
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_available
    debugger
    assert Ntp.available?
  end

  def test_available_not_perm
    Ntp.instance_variable_set(:@permissions,nil) #reset permissions cache
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources :"org.opensuse.yast.modules.yapi.ntp" => "/ntp"
      mock.permissions "org.opensuse.yast.modules.yapi.ntp", { :available => true, :synchronize => false }
      mock.get  "/ntp.xml", @header, @response, 200
    end
    assert !Ntp.available?
  end

  def test_available_not_available
    response = fixture "ntp_unavailable.xml"
    Ntp.instance_variable_set(:@permissions,nil) #reset permissions cache
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources :"org.opensuse.yast.modules.yapi.ntp" => "/ntp"
      mock.permissions "org.opensuse.yast.modules.yapi.ntp", { :available => true, :synchronize => true }
      mock.get  "/ntp.xml", @header, response, 200
    end
    assert !Ntp.available?
  end

  def test_available_failed
    response = fixture "ntp_unavailable.xml"
    Ntp.instance_variable_set(:@permissions,nil) #reset permissions cache
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources :"org.opensuse.yast.modules.yapi.ntp" => "/ntp"
      mock.permissions "org.opensuse.yast.modules.yapi.ntp", { :available => true, :synchronize => true }
      mock.get  "/ntp.xml", @header, "plugin missing", 404
    end
    assert !Ntp.available?
  end
end
