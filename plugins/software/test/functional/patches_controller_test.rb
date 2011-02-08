#--
# Copyright (c) 2011 Novell, Inc.
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

class PatchUpdatesControllerTest < ActionController::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    # disable authentication
    PatchUpdatesController.any_instance.stubs(:login_required)

    # stub what the REST is supposed to return
    ActiveResource::HttpMock.set_authentication
    @header = ActiveResource::HttpMock.authentication_header
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.patches" => "/patches"},
          { :policy => "org.opensuse.yast.system.patches"})
      mock.permissions "org.opensuse.yast.system.patches", { :read => true, :write => true }

      mock.get "/patches.xml", @header, fixture("patches.xml"), 200
      mock.get "/patches.xml?messages=true", @header, fixture("empty_messages.xml"), 200
    end
  end

  def test_update_license_require
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.patches" => "/patches"},
          { :policy => "org.opensuse.yast.system.patches"})
      mock.permissions "org.opensuse.yast.system.patches", { :read => true, :write => true }

      mock.get "/patches.xml", @header, fixture("error_license_confirmation.xml"), 503
      mock.get "/patches.xml?messages=true", @header, fixture("empty_messages.xml"), 200
    end
    get :index

    assert_redirected_to :action => "license"
  end

  def test_show_license
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.patches" => "/patches"},
          { :policy => "org.opensuse.yast.system.patches"})
      mock.permissions "org.opensuse.yast.system.patches", { :read => true, :write => true }

      mock.get "/patches.xml", @header, fixture("patches.xml"), 200
      mock.get "/patches.xml?messages=true", @header, fixture("empty_messages.xml"), 200
      mock.get "/patches.xml?license=1", @header, fixture("license.xml"), 200
    end

    get :license

    assert_response :success
  end

end
