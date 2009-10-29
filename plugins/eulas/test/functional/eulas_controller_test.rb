require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'

require 'mocha'

class EulasControllerTest < ActionController::TestCase
  
  class Proxy
    attr_accessor :result, :permissions, :timeout

    def initialize(result, permissions)
      @result = result
      @permissions = permissions
    end

    def find(*args)
      if args[0] == :all then
        @result
      else
        @result[0]
      end
    end

  end

  class Eula
    attr_accessor :id, :accepted, :name, :text, :text_lang, :available_langs, :only_show

    def initialize (name, accepted, available_langs, only_show)
      @name = name
      @accepted = accepted
      @available_langs = available_langs
      @only_show = only_show
    end

    def save
      @saved = true
    end
  end

  def setup
    EulasController.any_instance.stubs(:login_required)
    @controller = EulasController.new

    # setup for eulas controller tests
    @opensuse_eula = Eula.new ('openSUSE-11.1', false, ['en'], true)
    @sles_eula     = Eula.new ('SLES-11', false, ['en'], false)
    @proxy = Proxy.new([@opensuse_eula, @sles_eula], {:read=>true, :write=>true})
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.eulas').returns(@proxy)
 
  end

  def test_eula_start
    session[:eula_unaccepted_ids_cache] = nil
    get :index
    assert_redirected_to "/eulas/next"
    assert_not_nil session[:eula_unaccepted_ids_cache]
    get :next
    assert_redirected_to "/eulas/show/1"
  end

  def test_eula_step
    @opensuse_eula.accepted = false
    session[:eula_unaccepted_ids_cache] = [1,2]
    post :update, "accepted" => true, "id" => "1"
    assert_equal( session[:eula_unaccepted_ids_cache], [2] )
    post :update, "accepted" => false, "id" => "2"
    assert_equal( session[:eula_unaccepted_ids_cache], [2] )
    assert_redirected_to "/eulas/next"
  end

end
