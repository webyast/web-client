require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'mocha'

class StatusControllerTest < ActionController::TestCase

class Log
  attr_accessor :description,:id,:path
  def initialize(d,i,p)
    @description =d
    @id = i
    @path = p
  end
end

DEFINED_LOGS = [
  Log.new("test","test","/log/test"),
  Log.new("test2","test2","/log/test2")
]

  class StatusProxy
    attr_accessor :result, :permissions, :timeout
    def find(arg=nil)
      return {}
    end
  end

  class LogsProxy
    attr_accessor :result, :permissions, :timeout
    def find(arg)
      return @result
    end
  end

  def setup
    StatusController.any_instance.stubs(:login_required)
    @controller = StatusController.new
    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures
    @logs_proxy = LogsProxy.new
    @logs_proxy.result = DEFINED_LOGS
  end

  def test_index
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.system.logs').returns(@logs_proxy)
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.system.status').returns(StatusProxy.new)
    get :index

    assert_response :success
    assert_valid_markup
    assert assigns(:logs)
  end
end
