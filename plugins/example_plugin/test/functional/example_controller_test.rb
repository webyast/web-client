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

class ExampleControllerTest < ActionController::TestCase

  def services_fixtures
    git_loc = File.join(File.dirname(__FILE__),"..","..","..","services","test","fixtures","ntp.xml")
    if File.exists? git_loc
      IO.read git_loc
    else
      IO.read File.join( RailsParent.parent, "vendor", "plugins", "services", "test", "fixtures", "ntp.xml" )
    end
  end
  
  def setup
    Example.instance_variable_set(:@permissions,nil) #reset permissions cache
    ExampleController.any_instance.stubs(:login_required)
    @controller = ExampleController.new
    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures
    @response_example = IO.read(File.join(File.dirname(__FILE__),"..","fixtures","example.xml"))
    ActiveResource::HttpMock.set_authentication
    @header = ActiveResource::HttpMock.authentication_header
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources  :"org.opensuse.yast.system.example" => "/example"
      mock.permissions "org.opensuse.yast.system.example", { :read => true, :write => true }
      mock.get   "/example.xml", @header, @response_example, 200
      mock.post   "/example.xml", @header, @response_example, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_index
    get :index
    assert_response :success
    assert_valid_markup
  end

  def test_commit
    post :update, "example"=>{"content"=>"test"}
    assert_response :success
    assert_valid_markup
    #checking if the rest service has been called
    assert ActiveResource::HttpMock.requests.any? {
        |r| r.method == :post && r.path == "/example.xml"}
  end


end
