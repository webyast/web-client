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
