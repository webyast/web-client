#
# main_controller_test.rb
#
require File.dirname(__FILE__) + '/../test_helper'

class MainControllerTest < ActionController::TestCase
  fixtures :accounts

  def test_index_no_session
    @request.session[:account_id] = nil
    get :index
    assert_redirected_to :controller => "session", :action => "new"
  end
  
  def test_index_with_session
    # Fake an active session
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = Account.find(:first).id
    get :index
    assert_redirected_to :controller => "controlpanel", :action => "index"	
  end
end
