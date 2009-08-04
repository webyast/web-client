require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'rubygems'
require 'mocha'



class LanguageControllerTest < ActionController::TestCase
 # fixtures :accounts

  class Proxy
    attr_accessor :result, :permissions, :timeout
    def find
      return result
    end
  end

  class Lang
    attr_accessor :id, :name
    def initialize (id,name)
      @id = id
      @name = name
    end
  end

  class Result
    attr_accessor :available,
      :current,
      :utf8,
      :rootlocale,
      :saved

    def fill
      @available = [Lang.new("cs_CZ","cestina"),
        Lang.new("en_US","English (US)")
      ];
      @current = "cs_CZ"
      @utf8 = "true"
      @rootlocale = "false"
    end

    def save
      @saved = true
    end
  end

  def setup
    LanguageController.any_instance.stubs(:login_required)
    @controller = LanguageController.new
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
  
  def test_access_index
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.yapi.language').returns(@proxy)
    get :index

    #check if everything is correctly setted
    assert_response :success
    assert_valid_markup
    assert assigns(:permissions) , "Permission is not set"
    assert assigns(:permissions)[:read], "Read permission is not set"
    assert assigns(:permissions)[:write], "Write permission is not set"
    assert_equal assigns(:valid), ["cestina","English (US)"].sort
    assert_equal assigns(:current), "cestina"
    assert_equal assigns(:utf8), @result.utf8
    assert_equal assigns(:rootlocale), @result.rootlocale

    #test if options is correctly rendered
    rootlocale = {:tag => "select",
      :attributes => {
        :name => "rootlocale"
      }}
    assert_tag rootlocale
    assert_tag :tag => "option",
      :attributes => {
        :value => "false",
        :selected => "selected"
      },
      :parent => rootlocale
    assert_tag :tag => "input",
      :attributes => {
        :name => "utf8",
        :checked => "checked"
      }
    langs = {
      :tag => "select",
      :attributes => {
        :name => "first_language"
      }
    }
    assert_tag langs
    assert_tag :tag => "option",
      :attributes => {
        :value => "cestina",
        :selected => "selected"
      },
      :parent => langs

  end

  def test_access_without_write_permissions
    @permissions[:write] = false
    @result.utf8 = "false"
    @result.rootlocale = "true"
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.yapi.language').returns(@proxy)

    get :index

    assert_response :success
    assert_valid_markup
    assert assigns(:permissions)
    assert assigns(:permissions)[:read]
    assert !assigns(:permissions)[:write]
    assert_equal assigns(:valid), ["cestina","English (US)"].sort
    assert_equal assigns(:current), "cestina"
    assert_equal assigns(:utf8), @result.utf8
    assert_equal assigns(:rootlocale), @result.rootlocale

    #test if options is correctly rendered
    rootlocale = {:tag => "select",
      :attributes => {
        :name => "rootlocale",
        :disabled => "disabled"
      }}
    assert_tag rootlocale
    assert_tag :tag => "option",
      :attributes => {
        :value => "true",
        :selected => "selected"
      },
      :parent => rootlocale
    assert_tag :tag => "input",
      :attributes => {
        :name => "utf8",
        :disabled => "disabled"
      }
    langs = {
      :tag => "select",
      :attributes => {
        :name => "first_language",
        :disabled => "disabled"
      }
    }
    assert_tag langs
    assert_tag :tag => "option",
      :attributes => {
        :value => "cestina",
        :selected => "selected"
      },
      :parent => langs
    assert_tag :tag => "input",
      :attributes => {
        :type => "submit",
        :name => "commit",
        :value => "Save",
        :disabled => "disabled"
      }

  end


  def test_commit
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.modules.yapi.language').returns(@proxy)
    post :commit_language, { :first_language => "English (US)", :rootlocale => "ctype" }

    assert_response :redirect
    assert_redirected_to :action => "index"

    assert_equal "en_US", @result.current
    assert_equal "false", @result.utf8
    assert_equal "ctype", @result.rootlocale
    assert @result.saved
  end

end
