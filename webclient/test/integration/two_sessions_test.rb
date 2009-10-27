require 'test_helper'
begin
  require 'fakeweb'
rescue LoadError
  puts "fakeweb not found, skipping two_session_test"
  exit 0
end

FakeWeb.allow_net_connect = false

class TwoSessionsTest < ActionController::IntegrationTest
  private

  def load_fakeweb_uri(username)
    page = File.read(Rails.root.join("test", "fixtures", "ws-responses", "login-#{username}.curl"))
    FakeWeb.register_uri(:post, "https://localhost/login.xml", :response => page)
  end

  public

  test "don't mix up 2 valid sessions" do
    user1 = login("good")
    assert_equal "good", YaST::ServiceResource::Session.login

    user2 = login("better")
    assert_equal "better", YaST::ServiceResource::Session.login

    user1.browses_site
    assert_equal "good", YaST::ServiceResource::Session.login

    user2.browses_site
    assert_equal "better", YaST::ServiceResource::Session.login
  end

  test "don't mix up valid and invalid sessions" do
    user1 = login("good")
    assert_equal "good", YaST::ServiceResource::Session.login

    user2 = login("bad")

    user1.browses_site
    assert_equal "good", YaST::ServiceResource::Session.login
  end

  private
  module CustomDsl
    def browses_site
      get "/controlpanel"
    end
  end

  def login(username)
    load_fakeweb_uri username
    open_session do |sess|
      sess.extend(CustomDsl)
      # hostid 2 is localhost in the fixtures
      sess.post "/session", :hostid => 2, :login => username, :password => "fake"
      # success = redirect further or back to login
      # failure (bad route) = 500...
      assert_equal "302", sess.response.code
    end
  end
end
