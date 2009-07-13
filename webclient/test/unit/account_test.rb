require File.dirname(__FILE__) + '/../test_helper'

class WebserviceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
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
