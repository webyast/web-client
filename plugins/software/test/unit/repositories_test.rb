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

class RepositoriesTest < ActiveSupport::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    # stub what the REST is supposed to return
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      mock.resources({:"org.opensuse.yast.system.repositories" => "/repositories"},
          { :policy => "org.opensuse.yast.system.repositories"})
      mock.permissions "org.opensuse.yast.system.repositories", { :read => true, :write => true }

      # valid requests
      mock.get  "/repositories.xml", header, fixture("repositories.xml"), 200
      mock.get  "/repositories/Ruby.xml", header, fixture("repository_Ruby.xml"), 200

      # invalid request (requesting non-existing repository), return 404 error code
      mock.get  "/repositories/missing.xml", header, fixture("error_message.xml"), 404
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_find_all
    res = Repository.find :all
    assert res
    assert_equal 'Factory (Non-OSS)', res.first.name
    assert_equal 'Factory_(Non-OSS)', res.first.id
  end

  def test_find_ruby
    res = Repository.find 'Ruby'
    assert res
    assert_equal 'Ruby', res.name
    assert_equal 'Ruby', res.id
  end

  def test_find_missing
    assert_raise ActiveResource::ResourceNotFound do
      Repository.find 'missing'
    end
  end

end
