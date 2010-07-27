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
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'yast_mock'
require 'mocha'

class ServicesControllerTest < ActionController::TestCase

  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end


  def setup
    ServicesController.any_instance.stubs(:login_required)
    @request = ActionController::TestRequest.new
    response_services	= fixture("services.xml")
    response_ntp	= fixture("ntp.xml")
    response_ntp_stop	= fixture("ntp-stop.xml")
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.services" => "/services"
      mock.permissions "org.opensuse.yast.modules.yapi.services", { :read => true, :write => true, :execute => true}
      mock.get   "/services.xml?read_status=1", header, response_services, 200
      mock.get   "/services/ntp.xml?custom=false", header, response_ntp, 200
      mock.put	"/services/ntp.xml?custom=false&execute=stop", header, response_ntp_stop, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_index
    get :index
    assert_response :success
    assert_valid_markup
    assert_not_nil assigns(:services)
  end

  def test_index_failure
    response_failed = fixture("services-failed.xml")
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources  :"org.opensuse.yast.modules.yapi.services" => "/services"
      mock.permissions "org.opensuse.yast.modules.yapi.services", { :read => true, :write => true, :execute => true}
      mock.get   "/services.xml?read_status=1", header, response_failed, 500
    end
    get :index
    assert_response :success
    assert_not_nil assigns(:services)
    #check if flash error is written
    assert_tag :span, :attributes => { :class => "ui-icon ui-icon-alert" }

# JR: cannot be test, because flash object is already used during render, so it is not passed to response
#    assert flash[:error]
  end

  def test_ntp_status
    ret = get :show_status, {:id => 'ntp', :custom => false}
    assert_response :success
    assert !ret.body.index("not running").nil? # fixture status is 3 = not running
  end

  def test_nonexistent_service_status
    response_aaa = fixture("aaa.xml")
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.get   "/services/aaa.xml?custom=false", header, response_aaa, 500
    end
    ret = get :show_status, {:id => 'aaa', :custom => false}
    assert_equal ret.body, '(cannot read status)'
    assert_response :success
  end

  def test_execute
    put :execute, { :service_id => 'ntp', :id => 'stop', :custom => false}
    assert assigns(:error_string), "success"
    assert assigns(:result_string), "Shutting down network time protocol daemon (NTPD)\n"
  end

end

