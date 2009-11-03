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
        @result[args[0]-1]
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
    session[:eula_count] = nil
    get :index
    assert_redirected_to "/eulas/show/1"
    assert_not_nil session[:eula_count]
  end

  def test_eula_step
    @opensuse_eula.accepted = false
    get :index
    post :update, "accepted" => true, "id" => "1"
    assert( @opensuse_eula.accepted )
    assert_redirected_to "/eulas/show/2"
    post :update, "accepted" => false, "id" => "2"
    assert_false(@sles_eula.accepted)
    assert_redirected_to "/eulas/show/2"
    post :update, "accepted" => true, "id" => "2"
    assert(@sles_eula.accepted)
    assert_redirected_to "/eulas" # in basesystem redirected to "/controller/nextstep"
  end

end
