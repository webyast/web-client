require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )

class UsersControllerTest < ActionController::TestCase

  class Proxy
    attr_accessor :result, :permissions, :timeout
    def find
      return result
    end
  end

  class Result

    def fill
    end

    def save
      return true
    end
  end

  def setup
    @request = ActionController::TestRequest.new

    @result = Result.new
    @result.fill

    @proxy = Proxy.new
    @proxy.permissions = { :read => true, :write => true }
    @proxy.result = @result
 
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.yapi.users').returns(@proxy)

    @controller = UsersController.new
    UsersController.any_instance.stubs(:login_required)
  end
  
end
