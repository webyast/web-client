require File.dirname(__FILE__) + '/../test_helper'

require 'mocha'

require 'active_resource/http_mock'

class ControlpanelControllerTest < ActionController::TestCase
  fixtures :accounts, :hosts

  def setup
    @host = Host.find(1)
    current_account = Account.new
    auth_token = "abcdef"
    Account.stubs(:authenticate).with("quentin","test",@host.url).returns([current_account, auth_token])
    Account.stubs(:authenticate).with("quentin","bad password",@host.url).returns([nil,nil])
    Account.stubs(:authenticate).with("quentin","exception",@host.url).raises(RuntimeError)
    Account.stubs(:authenticate).with("quentin","bad host",@host.url).raises(Errno::ECONNREFUSED)
    YaST::ServiceResource::Session.site = @host.url
    ActiveResource::Base.site = @host.url
  end

  test "controlpanel index" do
    get :index
    assert :success
  end
end
