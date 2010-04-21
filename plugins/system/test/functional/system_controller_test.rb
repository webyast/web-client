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

class SystemControllerTest < ActionController::TestCase

  class Proxy
    attr_accessor :result, :permissions, :timeout
    def find
      return result
    end
  end

  class Action
    attr_accessor :active

    def initialize
	@active = false 
    end
  end

  class Result
    attr_accessor :reboot, :shutdown

    def fill
	@reboot = Action.new
	@shutdown = Action.new
    end

    def save
      return true
    end
  end

  def setup
    @request = ActionController::TestRequest.new

    @result = Result.new
    @result.fill

    @proxy = Proxy.new
    @proxy.permissions = { :read => true, :write => true }
    @proxy.result = @result
 
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.system.system').returns(@proxy)

    @controller = SystemController.new
    SystemController.any_instance.stubs(:login_required)
  end
  
  test "'reboot' not accpeted via GET" do
    ret = get :reboot

    # redirected to the control panel?
    assert_response :found
    assert_redirected_to :controller => :controlpanel, :action => :index

    # error reported?
    assert !ret.flash[:error].blank?
  end

  test "'shutdown' not accpeted via GET" do
    ret = get :shutdown

    # redirected to the control panel?
    assert_response :found
    assert_redirected_to :controller => :controlpanel, :action => :index

    # error reported?
    assert !ret.flash[:error].blank?
  end

  test "check 'shutdown' result" do
    ret = put :shutdown

    # redirected to the control panel?
    assert_response :found
    assert_redirected_to :controller => :logout

    # no error and a message present?
    assert ret.flash[:error].blank?
    assert !ret.flash[:message].blank?
  end

  test "check 'reboot' result" do
    ret = put :reboot

    # redirected to the control panel?
    assert_response :found
    assert_redirected_to :controller => :logout

    # no error and a message present?
    assert ret.flash[:error].blank?
    assert !ret.flash[:message].blank?
  end

  test "check 'shutdown' failed" do
    Result.any_instance.stubs(:save).returns(false)
    ret = put :shutdown

    # redirected to the control panel?
    assert_response :found
    assert_redirected_to :controller => :controlpanel, :action => :index

    # error reported?
    assert !ret.flash[:error].blank?
    Result.any_instance.stubs(:save).returns(true)
  end

  test "check 'reboot' failed" do
    Result.any_instance.stubs(:save).returns(false)
    ret = put :reboot

    # redirected to the control panel?
    assert_response :found
    assert_redirected_to :controller => :controlpanel, :action => :index

    # error reported?
    assert !ret.flash[:error].blank?
    Result.any_instance.stubs(:save).returns(true)
  end

end
