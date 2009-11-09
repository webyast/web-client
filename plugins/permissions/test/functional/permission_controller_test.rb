require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'mocha'



class PermissionsControllerTest < ActionController::TestCase
 # fixtures :accounts

  class Proxy
    attr_accessor :result, :permissions, :timeout
    def find dummy1, dummy2
      return result.permissions
    end
  end

  class Permission
    attr_accessor  :granted, :id
    def initialize (name, grant)
      @granted = grant
      @id = name
    end
    def save
    end
  end

  class Result
    attr_accessor :permissions

    def fill
      @permissions = [Permission.new("org.opensuse.yast.webservice.read-permissions", true),
                      Permission.new("org.opensuse.yast.webservice.write-permissions", true),
                      Permission.new("org.opensuse.yast.modules.yapi.language.setcurrentlanguage", true),
                      Permission.new("org.opensuse.yast.system.network.read", true),
                      Permission.new("org.opensuse.yast.language.read-firstlanguage", true),
                      Permission.new("org.opensuse.yast.scr.error", false),
                      Permission.new("org.opensuse.yast.services.execute-commands-gpm", true),
                      Permission.new("org.opensuse.yast.scr.registeragent", false),
                      Permission.new("org.opensuse.yast.language.read", true),
                      Permission.new("org.opensuse.yast.systemtime.write-timezone", true),
                      Permission.new("org.opensuse.yast.services.read-config-ntp-manualserver", true),
                      Permission.new("org.opensuse.yast.system.services.execute", true),
                      Permission.new("org.opensuse.yast.system.users.write", true),
                      Permission.new("org.opensuse.yast.services.write-config", true),
                      Permission.new("org.opensuse.yast.system.users.delete", true),
                      Permission.new("org.opensuse.yast.system.patches.read", true),
                      Permission.new("org.opensuse.yast.system.time.read", true),
                      Permission.new("org.opensuse.yast.language.read-secondlanguages", true),
                      Permission.new("org.opensuse.yast.services.read", true),
                      Permission.new("org.opensuse.yast.system.users.read", true),
                      Permission.new("org.opensuse.yast.system.patches.install", true),
                      Permission.new("org.opensuse.yast.permissions.write", true),
                      Permission.new("org.opensuse.yast.language.write", true),
                      Permission.new("org.opensuse.yast.modules.yapi.users.useradd", true),
                      Permission.new("org.opensuse.yast.scr.unregisteragent", false),
                      Permission.new("org.opensuse.yast.services.read-config-ntp-enabled", true),
                      Permission.new("org.opensuse.yast.scr.execute", false),
                      Permission.new("org.opensuse.yast.modules.yapi.language.setutf8", true),
                      Permission.new("org.opensuse.yast.scr.unregisterallagents", false),
                      Permission.new("org.opensuse.yast.services.write-config-ntp", true),
                      Permission.new("org.opensuse.yast.module-manager.import", true),
                      Permission.new("org.opensuse.yast.modules.yapi.time.write", true),
                      Permission.new("org.opensuse.yast.services.execute-commands", true),
                      Permission.new("org.opensuse.yast.scr.dir", false),
                      Permission.new("org.opensuse.yast.modules.yapi.language.getlanguages", true),
                      Permission.new("org.opensuse.yast.systemtime.write", true),
                      Permission.new("org.opensuse.yast.system.status.writelimits", true),
                      Permission.new("org.opensuse.yast.system.time.write", true),
                      Permission.new("org.opensuse.yast.language.read-available", true),
                      Permission.new("org.opensuse.yast.services.execute-commands-random", true),
                      Permission.new("org.opensuse.yast.modules.yapi.users.usersget", true),
                      Permission.new("org.opensuse.yast.system.security.write", true),
                      Permission.new("org.opensuse.yast.permissions.read", true),
                      Permission.new("org.opensuse.yast.system.services.read", true),
                      Permission.new("org.opensuse.yast.services.execute", true),
                      Permission.new("org.opensuse.yast.services.execute-commands-ntp", true),
                      Permission.new("org.opensuse.yast.services.execute-commands-smbfs", true),
                      Permission.new("org.opensuse.yast.services.write-config-ntp-enabled", true),
                      Permission.new("org.opensuse.yast.scr.read", false),
                      Permission.new("org.opensuse.yast.modules.yapi.language.getcurrentlanguage", true),
                      Permission.new("org.opensuse.yast.systemtime.read", true),
                      Permission.new("org.opensuse.yast.modules.yapi.time.read", true),
                      Permission.new("org.opensuse.yast.scr.write", false),
                      Permission.new("org.opensuse.yast.patch.install", true),
                      Permission.new("org.opensuse.yast.modules.yapi.language.isutf8", true),
                      Permission.new("org.opensuse.yast.system.services.write", true),
                      Permission.new("org.opensuse.yast.services.write-config-ntp-manualserver", true),
                      Permission.new("org.opensuse.yast.system.language.read", true),
                      Permission.new("org.opensuse.yast.services.write", true),
                      Permission.new("org.opensuse.yast.scr.registernewagents", false),
                      Permission.new("org.opensuse.yast.language.write-secondlanguages", true),
                      Permission.new("org.opensuse.yast.modules.yapi.language.write", true),
                      Permission.new("org.opensuse.yast.system.status.read", true),
                      Permission.new("org.opensuse.yast.system.users.new", true),
                      Permission.new("org.opensuse.yast.services.execute-commands-sshd", true),
                      Permission.new("org.opensuse.yast.systemtime.read-validtimezones", true),
                      Permission.new("org.opensuse.yast.systemtime.read-isutc", true),
                      Permission.new("org.opensuse.yast.scr.unmountagent", false),
                      Permission.new("org.opensuse.yast.language.write-firstlanguage", true),
                      Permission.new("org.opensuse.yast.module-manager.lock", true),
                      Permission.new("org.opensuse.yast.modules.yapi.users.userdelete", true),
                      Permission.new("org.opensuse.yast.services.read-config-ntp-userandomserverw", true),
                      Permission.new("org.opensuse.yast.modules.yapi.language.setrootlang", true),
                      Permission.new("org.opensuse.yast.modules.yapi.language.read", true),
                      Permission.new("org.opensuse.yast.system.network.writelimits", true),
                      Permission.new("org.opensuse.yast.systemtime.write-isutc", true),
                      Permission.new("org.opensuse.yast.systemtime.write-currenttime", true),
                      Permission.new("org.opensuse.yast.modules.yapi.users.userget", true),
                      Permission.new("org.opensuse.yast.patch.read", true),
                      Permission.new("org.opensuse.yast.services.execute-commands-cups", true),
                      Permission.new("org.opensuse.yast.system.security.read", true),
                      Permission.new("org.opensuse.yast.systemtime.read-currenttime", true),
                      Permission.new("org.opensuse.yast.system.language.write", true),
                      Permission.new("org.opensuse.yast.modules.yapi.language.getrootlang", true),
                      Permission.new("org.opensuse.yast.systemtime.read-timezone", true),
                      Permission.new("org.opensuse.yast.services.execute-commands-cron", true),
                      Permission.new("org.opensuse.yast.services.read-config-ntp", true),
                      Permission.new("org.opensuse.yast.services.write-config-ntp-userandomserverw", true),
                      Permission.new("org.opensuse.yast.services.read-config", true),
                      Permission.new("org.opensuse.yast.modules.yapi.users.usermodify", true)

      ];
    end


  end

  def setup
    PermissionsController.any_instance.stubs(:login_required)
    @controller = PermissionsController.new
    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures
    @result = Result.new
    @result.fill
    @proxy = Proxy.new
    @proxy.permissions = @permissions
    @proxy.result = @result
    PermissionsController.any_instance.stubs(:client_permissions).with().returns(@proxy)
  end
  
  def test_permission_index
    get :index

    #check if everything is correctly setted
    assert_response :success
    assert_valid_markup
  end

  def test_permission_search
    get :search, {:user =>"test" }

    #check if everything is correctly setted
    assert_response :success
    assert_valid_markup
  end
=begin
disable setting, not required to first release
  def test_permission_set
    post :set, { "org.opensuse.yast.patch.install"=>"revoke", :user =>"test" }

    assert_response :success
    assert_valid_markup
  end
=end

end
