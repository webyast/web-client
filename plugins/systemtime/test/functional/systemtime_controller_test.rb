require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'rubygems'
require 'mocha'

class SystemtimeControllerTest < ActionController::TestCase

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
    attr_accessor :time, :date, :timezone, :utcstatus, :timezones, :saved

    def fill
	@timezones = [
		Region.new("Europe","Europe/Prague",[ Entry.new("Europe/Prague","Czech Republic" )])
]
        @time = "12:18:00"
        @date = "07/02/2009"
        @utcstatus = "true"
        @timezone = "Europe/Prague"
    end

    def save
      @saved = true
    end
  end

  def setup
    SystemtimeController.any_instance.stubs(:login_required)
    @controller = SystemtimeController.new
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
    assert_valid_markup
    assert assigns(:permissions)
    assert assigns(:permissions)[:read]
    assert assigns(:permissions)[:write]
    assert assigns(:time)
    assert assigns(:date)
    assert_equal assigns(:timezone), "Europe/Prague"
    assert assigns(:utcstatus)
  end

  def test_access_without_write_permissions
    @permissions[:write] = false
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.yapi.time').returns(@proxy)

    get :index

    assert_response :success
    assert_valid_markup
    assert assigns(:permissions)
    assert assigns(:permissions)[:read]
    assert !assigns(:permissions)[:write]
    assert assigns(:time)
  end


  def test_commit
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.yapi.time').returns(@proxy)
    post :update, { :currenttime => "2009-07-02 - 12:18:00", :date => { :date => "2009-07-02 - 12:18:00/2009-07-02 - 12:18:00" }, :utc => "true" }    
    assert_response :redirect
    assert_redirected_to :action => "index"

    assert @result.saved
  end

  def test_failing_permissions
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.yapi.time').returns(@proxy)
    def @proxy.permissions
      raise "Cannot find permission"
    end

    get :index

    assert_response :redirect
    assert_redirected_to "/bad_permissions"
  end

  def test_commit_wizard
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.yapi.time').returns(@proxy)
    session[:wizard_current] = "test"
    post :update, { :currenttime => "2009-07-02 - 12:18:00", :date => { :date => "2009-07-02 - 12:18:00/2009-07-02 - 12:18:00" }, :utc => "true" }    

    puts @response.body
    assert_response :redirect
    assert_redirected_to :action => "index"

    assert @result.saved
  end

end
