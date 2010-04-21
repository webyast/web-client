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

class FirewallControllerTest < ActionController::TestCase
  def setup
    FirewallController.any_instance.stubs(:login_required)
    @controller = FirewallController.new
    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures
    response_firewall = IO.read(File.join(File.dirname(__FILE__),"..","fixtures","firewall.xml"))
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.firewall" => "/firewall"
      mock.permissions "org.opensuse.yast.modules.yapi.firewall", { :read => true, :write => true }
      mock.get  "/firewall.xml", header, response_firewall, 200
      mock.post "/firewall.xml", header, response_firewall, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_index
    get :index
    assert_response :success
    assert_valid_markup
    assert assigns(:firewall)
    assert assigns(:permissions)
    assert assigns(:cgi_prefix)
  end

  def test_commit
    post :update, { :use_firewall => "true",
                    :"firewall_service:webyast-ui" => "true",
                    :"firewall_service:vnc-server" => "true"
                  }
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "index"
  end

  def test_commit_wizard
    Basesystem.stubs(:installed?).returns(true)
    session[:wizard_current] = "test"
    session[:wizard_steps] = "firewall,language"
    post :update, { :use_firewall => "true",
                    :"firewall_service:webyast-ui" => "true",
                    :"firewall_service:vnc-server" => "true"
                  }

    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "nextstep"
  end
end
