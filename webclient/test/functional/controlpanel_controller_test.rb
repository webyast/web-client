#--
# Webyast Webservice framework
#
# Copyright (C) 2009, 2010 Novell, Inc. 
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation. 
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details. 
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++

require File.dirname(__FILE__) + '/../test_helper'

class ControlpanelControllerTest < ActionController::TestCase

  def simulate_running_basesystem
    response_bs = load_xml_response "basesystem.xml"
    request_bs = load_xml_response "basesystem-response.xml"
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      # this is inadequate, :singular is per resource,
      # and does NOT depend on :policy
      # see yast-rest-service/plugins/network/config/resources/*
      mock.resources :"org.opensuse.yast.modules.basesystem" => "/basesystem"
      mock.permissions "org.opensuse.yast.modules.basesystem", {}
      mock.get  "/basesystem.xml", header, response_bs, 200
      mock.post  "/basesystem.xml", header, request_bs, 200
    end
  end

  def setup
    ControlpanelController.any_instance.stubs(:ensure_login)
    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures
    response_bs = load_xml_response "basesystem-complete.xml"
    request_bs = load_xml_response "basesystem-response.xml"
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      # this is inadequate, :singular is per resource,
      # and does NOT depend on :policy
      # see yast-rest-service/plugins/network/config/resources/*
      mock.resources :"org.opensuse.yast.modules.basesystem" => "/basesystem"
      mock.permissions "org.opensuse.yast.modules.basesystem", {}
      mock.get  "/basesystem.xml", header, response_bs, 200
      mock.post  "/basesystem.xml", header, request_bs, 200
    end
  end

  test "controlpanel index" do
    get :index
    assert_response :success
  end

  test "controlpanel all modules by groups" do
    get :show_all
    assert_response :success
  end

  test "next step action without initialized basesystem" do
    simulate_running_basesystem
    get :nextstep, :done => "time"
    assert_response :redirect
    assert_redirected_to "/controlpanel"
  end

  test "next step action" do
    simulate_running_basesystem
    get :index #require to initialize session
    get :nextstep, :done => "controlpanel"
    assert_response :redirect
    assert_redirected_to "/sessions"
  end

  test "next step action with wrong done parameter" do
    simulate_running_basesystem
    get :index #require to initialize session
    get :nextstep, :done => "language"
    assert_response :redirect
    assert_redirected_to "/controlpanel/nextstep"
  end

  test "this step action" do
    response_bs = load_xml_response "basesystem.xml"
    request_bs = load_xml_response "basesystem-response.xml"
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      # this is inadequate, :singular is per resource,
      # and does NOT depend on :policy
      # see yast-rest-service/plugins/network/config/resources/*
      mock.resources :"org.opensuse.yast.modules.basesystem" => "/basesystem"
      mock.permissions "org.opensuse.yast.modules.basesystem", {}
      mock.get  "/basesystem.xml", header, response_bs, 200
      mock.post  "/basesystem.xml", header, request_bs, 200
    end

    get :index #require to initialize session
    get :thisstep
    assert_response :redirect
    assert_redirected_to "/controlpanel/nextstep"
  end

  test "back step action on first element" do
    response_bs = load_xml_response "basesystem.xml"
    request_bs = load_xml_response "basesystem-response.xml"
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      # this is inadequate, :singular is per resource,
      # and does NOT depend on :policy
      # see yast-rest-service/plugins/network/config/resources/*
      mock.resources :"org.opensuse.yast.modules.basesystem" => "/basesystem"
      mock.permissions "org.opensuse.yast.modules.basesystem", {}
      mock.get  "/basesystem.xml", header, response_bs, 200
      mock.post  "/basesystem.xml", header, request_bs, 200
    end

    get :index #require to initialize session
    get :backstep
    assert_response :redirect
    assert_redirected_to "/controlpanel/nextstep"
  end
end
