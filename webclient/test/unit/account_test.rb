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

class AccountTest < ActiveSupport::TestCase
  
  def setup
    # stub Account so it doesn't need a real endpoint
    Account.stubs(:authenticate).with("login", "passwd", "http://localhost:8080").returns(["account", "token"])
    Account.stubs(:authenticate).with("login", "passwd", "localhost:8080").returns(["account", "token"])
  end
  
  # create account
  test "account create" do
    account, token = Account.authenticate "login", "passwd", "http://localhost:8080"
    assert account
    assert token
  end
  
  # test without "http://" prefix in url
  test "account create incomplete uri" do
    account, token = Account.authenticate "login", "passwd", "localhost:8080"
    assert account
    assert token
  end
end
