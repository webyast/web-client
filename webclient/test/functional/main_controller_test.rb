#
# main_controller_test.rb
#
require File.dirname(__FILE__) + '/../test_helper'

class MainControllerTest < ActionController::TestCase
  fixtures :accounts

  test "main index no session" do
    @request.session[:account_id] = nil
    get :index
    assert_redirected_to :controller => "session", :action => "new"
  end
  
  test "main index with session" do
    # Fake an active session
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = Account.find(:first).id
    get :index
    assert_redirected_to :controller => "controlpanel", :action => "index"	
  end
end
