require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require 'rubygems'
require 'mocha'

class SystemTimeControllerTest < ActionController::TestCase

  class Proxy
    attr_accessor :result, :permissions, :timeout
    def find
      return result
    end
  end

  class  Region
   attr_accessor :name, :central, :entries
    def initialize (name, central, entries)
      @name = name
      @central = central
      @entries = entries
    end
  end

  class Entry
    attr_accessor :id, :name
    def initialize (id,name)
      @id = id
      @name = name
    end
  end



  class Result
    attr_accessor :time, :timezone, :utcstatus, :timezones, :saved

    def fill
	@timezones = [
		Region.new("Europe","Europe/Prague",[ Entry.new("Europe/Prague","Czech Republic" )])
]
        @time = "2009-07-02 - 12:18:00"
        @utcstatus = "true"
        @timezone = "Europe/Prague"
#      @available = [Lang.new("cs_CZ","cestina"),
#        Lang.new("en_US","English (US)")
#      ];
#      @current = "cs_CZ"
#      @utf8 = "true"
#      @rootlocale = "false"
    end

    def save
      @saved = true
    end
  end

  def setup
    SystemTimeController.any_instance.stubs(:login_required)
    @controller = SystemTimeController.new
    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures
    @permissions = { :read => true, :write => true }
    @result = Result.new
    @result.fill
    @proxy = Proxy.new
    @proxy.permissions = @permissions
    @proxy.result = @result
  end

def test_index
 YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.yapi.time').returns(@proxy)
#debugger
 get :index
 assert_response :success
 assert assigns(:permissions)
 assert assigns(:permissions)[:read]
 assert assigns(:permissions)[:write]
 assert assigns(:time)
# assert assigns(:timezone), "Europe/Prague"
# assert assigns(:utcstatus)

end

end
