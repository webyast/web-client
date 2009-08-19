# host.rb
  require 'rubygems'
  require 'active_support'
  require 'sinatra'

  post '/login.xml' do
    req = Hash.from_xml request.env["rack.input"].read
    login = Hash.new
    if req["hash"]["login"] == "webyast_guest"
      login["login"] = "revoked"
    else
      login["login"] = "granted"
      login["auth_token"] = {"expires"=>"Tue Aug 18 07:08:22 UTC 2009", "value"=>"3e3910533595dd5657c54c32f27fc6068df96873"}
    end
    login.to_xml
  end

  post '/logout.xml' do
    logout = Hash.new
    logout["logout"] = "Goodbye!"
    logout.to_xml
  end

  get '/resources.xml' do
    resources = [{"interface" => "org.opensuse.yast.modules.yapi.time",
                 "singular" => true,
                 "href" => "time"},
                {"interface" => "org.opensuse.yast.modules.yapi.users",
                 "singular" => true,
                 "href" => "users"},
                {"interface" => "org.opensuse.yast.modules.yapi.language",
                 "singular" => true,
                 "href" => "language"},
                {"interface" => "org.opensuse.yast.system.services",
                 "singular" => true,
                 "href" => "services"},
                {"interface" => "org.opensuse.yast.system.patches",
                 "singular" => true,
                 "href" => "patches"},
                {"interface" => "org.opensuse.yast.system.security",
                 "singular" => true,
                 "href" => "security"},
                {"interface" => "org.opensuse.yast.system.networks",
                 "singular" => true,
                 "href" => "networks"},
                {"interface" => "org.opensuse.yast.system.sambashares",
                 "singular" => true,
                 "href" => "sambashares"},
                {"interface" => "org.opensuse.yast.system.system",
                 "singular" => true,
                 "href" => "system"},
                {"interface" => "org.opensuse.yast.system.status",
                 "singular" => true,
                 "href" => "status"},
                {"interface" => "org.opensuse.yast.commandline",
                 "singular" => true,
                 "href" => "yast/commandline"}]
    resources.to_xml(:root => "resources")
  end 

  get '/permissions.xml' do
    permissions = [   {"name" => "org.opensuse.yast.webservice.read-permissions", "grant" => true},
                      {"name" => "org.opensuse.yast.webservice.write-permissions", "grant" => true},
                      {"name" =>"org.opensuse.yast.modules.yapi.language.setcurrentlanguage", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.network.read", "grant" => true},
                      {"name" =>"org.opensuse.yast.language.read-firstlanguage", "grant" => true},
                      {"name" =>"org.opensuse.yast.scr.error", "grant" => false},
                      {"name" =>"org.opensuse.yast.services.execute-commands-gpm", "grant" => true},
                      {"name" =>"org.opensuse.yast.scr.registeragent", "grant" => false},
                      {"name" =>"org.opensuse.yast.language.read", "grant" => true},
                      {"name" =>"org.opensuse.yast.systemtime.write-timezone", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.read-config-ntp-manualserver", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.services.execute", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.users.write", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.write-config", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.users.delete", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.patches.read", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.time.read", "grant" => true},
                      {"name" =>"org.opensuse.yast.language.read-secondlanguages", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.read", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.users.read", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.patches.install", "grant" => true},
                      {"name" =>"org.opensuse.yast.permissions.write", "grant" => true},
                      {"name" =>"org.opensuse.yast.language.write", "grant" => true},
                      {"name" =>"org.opensuse.yast.modules.yapi.users.useradd", "grant" => true},
                      {"name" =>"org.opensuse.yast.scr.unregisteragent", "grant" => false},
                      {"name" =>"org.opensuse.yast.services.read-config-ntp-enabled", "grant" => true},
                      {"name" =>"org.opensuse.yast.scr.execute", "grant" => false},
                      {"name" =>"org.opensuse.yast.modules.yapi.language.setutf8", "grant" => true},
                      {"name" =>"org.opensuse.yast.scr.unregisterallagents", "grant" => false},
                      {"name" =>"org.opensuse.yast.services.write-config-ntp", "grant" => true},
                      {"name" =>"org.opensuse.yast.module-manager.import", "grant" => true},
                      {"name" =>"org.opensuse.yast.modules.yapi.time.write", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.execute-commands", "grant" => true},
                      {"name" =>"org.opensuse.yast.scr.dir", "grant" => false},
                      {"name" =>"org.opensuse.yast.modules.yapi.language.getlanguages", "grant" => true},
                      {"name" =>"org.opensuse.yast.systemtime.write", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.status.writelimits", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.time.write", "grant" => true},
                      {"name" =>"org.opensuse.yast.language.read-available", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.execute-commands-random", "grant" => true},
                      {"name" =>"org.opensuse.yast.modules.yapi.users.usersget", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.security.write", "grant" => true},
                      {"name" =>"org.opensuse.yast.permissions.read", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.services.read", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.execute", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.execute-commands-ntp", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.execute-commands-smbfs", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.write-config-ntp-enabled", "grant" => true},
                      {"name" =>"org.opensuse.yast.scr.read", "grant" => false},
                      {"name" =>"org.opensuse.yast.modules.yapi.language.getcurrentlanguage", "grant" => true},
                      {"name" =>"org.opensuse.yast.systemtime.read", "grant" => true},
                      {"name" =>"org.opensuse.yast.modules.yapi.time.read", "grant" => true},
                      {"name" =>"org.opensuse.yast.scr.write", "grant" => false},
                      {"name" =>"org.opensuse.yast.patch.install", "grant" => true},
                      {"name" =>"org.opensuse.yast.modules.yapi.language.isutf8", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.services.write", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.write-config-ntp-manualserver", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.language.read", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.write", "grant" => true},
                      {"name" =>"org.opensuse.yast.scr.registernewagents", "grant" => false},
                      {"name" =>"org.opensuse.yast.language.write-secondlanguages", "grant" => true},
                      {"name" =>"org.opensuse.yast.modules.yapi.language.write", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.status.read", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.users.new", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.execute-commands-sshd", "grant" => true},
                      {"name" =>"org.opensuse.yast.systemtime.read-validtimezones", "grant" => true},
                      {"name" =>"org.opensuse.yast.systemtime.read-isutc", "grant" => true},
                      {"name" =>"org.opensuse.yast.scr.unmountagent", "grant" => false},
                      {"name" =>"org.opensuse.yast.language.write-firstlanguage", "grant" => true},
                      {"name" =>"org.opensuse.yast.module-manager.lock", "grant" => true},
                      {"name" =>"org.opensuse.yast.modules.yapi.users.userdelete", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.read-config-ntp-userandomserverw", "grant" => true},
                      {"name" =>"org.opensuse.yast.modules.yapi.language.setrootlang", "grant" => true},
                      {"name" =>"org.opensuse.yast.modules.yapi.language.read", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.network.writelimits", "grant" => true},
                      {"name" =>"org.opensuse.yast.systemtime.write-isutc", "grant" => true},
                      {"name" =>"org.opensuse.yast.systemtime.write-currenttime", "grant" => true},
                      {"name" =>"org.opensuse.yast.modules.yapi.users.userget", "grant" => true},
                      {"name" =>"org.opensuse.yast.patch.read", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.execute-commands-cups", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.security.read", "grant" => true},
                      {"name" =>"org.opensuse.yast.systemtime.read-currenttime", "grant" => true},
                      {"name" =>"org.opensuse.yast.system.language.write", "grant" => true},
                      {"name" =>"org.opensuse.yast.modules.yapi.language.getrootlang", "grant" => true},
                      {"name" =>"org.opensuse.yast.systemtime.read-timezone", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.execute-commands-cron", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.read-config-ntp", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.write-config-ntp-userandomserverw", "grant" => true},
                      {"name" =>"org.opensuse.yast.services.read-config", "grant" => true},
                      {"name" =>"org.opensuse.yast.modules.yapi.users.usermodify", "grant" => true}]
    permissions.to_xml(:root => "permissions")
  end 

  put '/permissions/:id.xml' do
    permission = {"name" => "org.opensuse.yast.webservice.return-permissions", "grant" => true}
    permission.to_xml(:root => "permission")
  end