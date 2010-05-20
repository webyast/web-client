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

class RepositoriesControllerTest < ActionController::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    # disable authentication
    RepositoriesController.any_instance.stubs(:login_required)

    # stub what the REST is supposed to return
    ActiveResource::HttpMock.set_authentication
    @header = ActiveResource::HttpMock.authentication_header
    ActiveResource::HttpMock.respond_to do |mock|
      
      mock.resources({:"org.opensuse.yast.system.repositories" => "/repositories"},
          { :policy => "org.opensuse.yast.system.repositories"})
      mock.permissions "org.opensuse.yast.system.repositories", { :read => true, :write => true }

      # valid requests
      mock.get  "/repositories.xml", @header, fixture("repositories.xml"), 200
      mock.get  "/repositories/Ruby.xml", @header, fixture("repository_Ruby.xml"), 200

      # invalid request (requesting non-existing repository), return 404 error code
      mock.get  "/repositories/missing.xml", @header, fixture("error_message.xml"), 404

      mock.delete "/repositories/missing.xml", @header, nil, 404
      mock.delete "/repositories/Ruby.xml", @header, nil, 200

      mock.put "/repositories/Ruby.xml", @header, nil, 200
      mock.put "/repositories/new_repo.xml", @header, nil, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_index
    get :index

    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories.xml", nil, @header))
    assert_response :success
    assert_valid_markup
    assert_not_nil assigns(:repos)
    assert flash.empty?
  end

  def test_index_error
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.repositories" => "/repositories"},
          { :policy => "org.opensuse.yast.system.repositories"})
      mock.permissions "org.opensuse.yast.system.repositories", { :read => true, :write => true }

      mock.get  "/repositories.xml", @header, nil, 404
    end

    get :index

    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories.xml", nil, @header))
    assert_response :success
    assert_valid_markup
    assert flash.empty?
  end

  def test_add
    get :add

    assert_not_nil assigns(:repo)
    assert_response :success
    assert_valid_markup
    assert flash.empty?
  end

  def test_destroy
    post :delete, :id => 'Ruby'

    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories/Ruby.xml", nil, @header))
    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:delete, "/repositories/Ruby.xml", nil, @header))

    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :index
    assert_false flash.empty?
  end

  def test_destroy_empty_id
    post :delete, :id => ''

    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :index
    assert_false flash.empty?
  end

  def test_destroy_missing
    post :delete, :id => 'missing'

    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories/missing.xml", nil, @header))
    assert !ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:delete, "/repositories/missing.xml", nil, @header))

    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :index
    assert_false flash.empty?
  end

  def test_destroy_failed
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.repositories" => "/repositories"},
          { :policy => "org.opensuse.yast.system.repositories"})
      mock.permissions "org.opensuse.yast.system.repositories", { :read => true, :write => true }

      mock.get  "/repositories/Ruby.xml", @header, fixture("repository_Ruby.xml"), 200
      mock.delete "/repositories/Ruby.xml", @header, nil, 404
    end

    post :delete, :id => 'Ruby'

    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories/Ruby.xml", nil, @header))
    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:delete, "/repositories/Ruby.xml", nil, @header))

    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :index
    assert_false flash.empty?
  end


  def test_update_empty_id
    put :update, :id => ''

    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :index
    assert_false flash.empty?
  end

  def test_update
    put :update, :id => 'Ruby', :repository => { :name => 'New name', :autorefresh => '0', :priority => '50', :url => 'http://example.com',
      :enabled => '0', :keep_packages => '0'}

    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories/Ruby.xml", nil, @header))
    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:put, "/repositories/Ruby.xml", nil, @header))

    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :index, :show => 'Ruby'
    assert_false flash.empty?
  end

  def test_update_unknown_error
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.repositories" => "/repositories"},
          { :policy => "org.opensuse.yast.system.repositories"})
      mock.permissions "org.opensuse.yast.system.repositories", { :read => true, :write => true }

      mock.get  "/repositories/Ruby.xml", @header, fixture("repository_Ruby.xml"), 200
      mock.put "/repositories/Ruby.xml", @header, nil, 404
    end

    put :update, :id => 'Ruby', :repository => { :name => 'New name', :autorefresh => '0', :priority => '50', :url => 'http://example.com',
      :enabled => '0', :keep_packages => '0'}

    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories/Ruby.xml", nil, @header))
    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:put, "/repositories/Ruby.xml", nil, @header))

    assert_response :redirect
    assert_redirected_to :action => "index", :show => 'Ruby'
    assert_false flash.empty?
  end

  def test_update_empty_error
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.repositories" => "/repositories"},
          { :policy => "org.opensuse.yast.system.repositories"})
      mock.permissions "org.opensuse.yast.system.repositories", { :read => true, :write => true }

      mock.get  "/repositories/Ruby.xml", @header, fixture("repository_Ruby.xml"), 200
      mock.put "/repositories/Ruby.xml", @header, fixture("error_message_empty.xml"), 404
    end

    put :update, :id => 'Ruby', :repository => { :name => 'New name', :autorefresh => '0', :priority => '50', :url => 'http://example.com',
      :enabled => '0', :keep_packages => '0'}

    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories/Ruby.xml", nil, @header))
    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:put, "/repositories/Ruby.xml", nil, @header))

    assert_response :redirect
    assert_redirected_to :action => "index", :show => 'Ruby'
    assert_false flash.empty?
  end


  def test_update_failed
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.repositories" => "/repositories"},
          { :policy => "org.opensuse.yast.system.repositories"})
      mock.permissions "org.opensuse.yast.system.repositories", { :read => true, :write => true }

      mock.get  "/repositories/Ruby.xml", @header, fixture("repository_Ruby.xml"), 200
      mock.put "/repositories/Ruby.xml", @header, fixture("error_message.xml"), 404
    end

    put :update, :id => 'Ruby', :repository => { :name => 'New name', :autorefresh => '0', :priority => '50', :url => 'http://example.com',
      :enabled => '0', :keep_packages => '0'}

    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories/Ruby.xml", nil, @header))
    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:put, "/repositories/Ruby.xml", nil, @header))

    assert_response :redirect
    assert_redirected_to :action => "index", :show => 'Ruby'
    assert_false flash.empty?
  end

  def test_update_missing
    put :update, :id => 'missing', :repository => { :name => 'New name', :autorefresh => '0', :priority => '50', :url => 'http://example.com',
      :enabled => '0', :keep_packages => '0'}

    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories/missing.xml", nil, @header))
    assert !ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:put, "/repositories/missing.xml", nil, @header))

    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :index
    assert_false flash.empty?
  end

  def test_update_missing_params
    put :update, :id => 'Ruby', :repository => {}

    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories/Ruby.xml", nil, @header))
    assert !ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:put, "/repositories/Ruby.xml", nil, @header))

    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :index, :show => 'Ruby'
    assert_false flash.empty?
  end

  def test_create
    post :create, :repository => { :name => 'New repo', :autorefresh => 'true', :priority => '99', :url => 'http://example.com',
      :enabled => '0', :keep_packages => '0', :id => 'new_repo'}

    assert !ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories/new_repo.xml", nil, @header))
    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:put, "/repositories/new_repo.xml", nil, @header))

    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :index, :show => 'new_repo'
    assert_false flash.empty?
  end

  def test_error_message_unknown_error
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.repositories" => "/repositories"},
          { :policy => "org.opensuse.yast.system.repositories"})
      mock.permissions "org.opensuse.yast.system.repositories", { :read => true, :write => true }
      mock.put "/repositories/new_repo.xml", @header, nil, 500
    end

    post :create, :repository => { :name => 'New repo', :autorefresh => 'true', :priority => '99', :url => 'http://example.com',
      :enabled => '0', :keep_packages => '0', :id => 'new_repo'}

    assert !ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories/new_repo.xml", nil, @header))
    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:put, "/repositories/new_repo.xml", nil, @header))

    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :add
    assert_false flash.empty?
  end

  def test_error_message_packagekit_error
    response_error_message = fixture "error_message.xml"
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.repositories" => "/repositories"},
          { :policy => "org.opensuse.yast.system.repositories"})
      mock.permissions "org.opensuse.yast.system.repositories", { :read => true, :write => true }
      mock.put "/repositories/new_repo.xml", @header, response_error_message, 404
    end

    post :create, :repository => { :name => 'New repo', :autorefresh => 'true', :priority => '99', :url => 'http://example.com',
      :enabled => '0', :keep_packages => '0', :id => 'new_repo'}

    assert !ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories/new_repo.xml", nil, @header))
    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:put, "/repositories/new_repo.xml", nil, @header))

    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :add
    assert_false flash.empty?
  end

  def test_create_empty_error
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.repositories" => "/repositories"},
          { :policy => "org.opensuse.yast.system.repositories"})
      mock.permissions "org.opensuse.yast.system.repositories", { :read => true, :write => true }
      mock.put "/repositories/new_repo.xml", @header, fixture("error_message_empty.xml"), 404
    end

    post :create, :repository => { :name => 'New repo', :autorefresh => 'true', :priority => '99', :url => 'http://example.com',
      :enabled => '0', :keep_packages => '0', :id => 'new_repo'}

    assert !ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories/new_repo.xml", nil, @header))
    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:put, "/repositories/new_repo.xml", nil, @header))

    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :add
    assert_false flash.empty?
  end

  def test_create_no_params
    post :create

    assert_response :redirect
    assert_valid_markup
    assert_redirected_to :action => :add
    assert_false flash.empty?
  end

  def test_create_error_invalid_priority
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.repositories" => "/repositories"},
          { :policy => "org.opensuse.yast.system.repositories"})
      mock.permissions "org.opensuse.yast.system.repositories", { :read => true, :write => true }
      mock.put "/repositories/new_repo.xml", @header, fixture("error_message_empty.xml"), 404
    end

    post :create, :repository => { :name => 'New repo', :autorefresh => 'true', :priority => 'asddf', :url => 'http://example.com',
      :enabled => 'false', :keep_packages => 'false', :id => 'new_repo'}

    assert !ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories/new_repo.xml", nil, @header))
    assert !ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:put, "/repositories/new_repo.xml", nil, @header))

    assert_response :success
    assert_valid_markup
  end

  def test_update_invalid_priority
    put :update, :id => 'Ruby', :repository => { :name => 'New name', :autorefresh => 'false', :priority => 'asdf', :url => 'http://example.com',
      :enabled => 'false', :keep_packages => 'false'}

    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories/Ruby.xml", nil, @header))
    assert !ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:put, "/repositories/Ruby.xml", nil, @header))

    assert_response :redirect
    assert_false flash.empty?
  end

  def test_update_validation_failed
    ActiveResource::HttpMock.respond_to do |mock|
      mock.resources({:"org.opensuse.yast.system.repositories" => "/repositories"},
          { :policy => "org.opensuse.yast.system.repositories"})
      mock.permissions "org.opensuse.yast.system.repositories", { :read => true, :write => true }
      mock.get  "/repositories/Ruby.xml", @header, fixture("repository_Ruby.xml"), 200
      # Content-Type is essential here, ActiveResource does not parse the response when the type is missing
      mock.put "/repositories/Ruby.xml", @header, fixture("error_validation_failed.xml"), 422, 'Content-Type' => 'application/xml'
    end

    put :update, :id => 'Ruby', :repository => { :name => 'New name', :autorefresh => '0', :priority => '50', :url => 'http://example.com',
      :enabled => '0', :keep_packages => '0'}

    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:get, "/repositories/Ruby.xml", nil, @header))
    assert ActiveResource::HttpMock.requests.include?(ActiveResource::Request.new(:put, "/repositories/Ruby.xml", nil, @header))

    assert_response :redirect
    assert_redirected_to :action => "index", :show => 'Ruby'
    assert_false flash.empty?
    assert_match(/Priority/, flash[:error])
  end

end
