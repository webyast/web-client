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

  get '/time.xml' do
    ret = Hash.from_xml <<EOX
<systemtime><time>09:12:16</time><date>20/08/2009</date><timezone>Europe/Berlin</timezone><utcstatus>UTC</utcstatus><timezones type="array"><region><name>Africa</name><central>Africa/Kampala</central><entries type="array"><timezone><id>Africa/Maputo</id><name>Maputo</name></timezone><timezone><id>Africa/Johannesburg</id><name>Johannesburg</name></timezone><timezone><id>Africa/Casablanca</id><name>Casablanca</name></timezone><timezone><id>Africa/Banjul</id><name>Banjul</name></timezone><timezone><id>Africa/Windhoek</id><name>Windhoek</name></timezone><timezone><id>Africa/Maseru</id><name>Maseru</name></timezone><timezone><id>Africa/Luanda</id><name>Luanda</name></timezone><timezone><id>Africa/Lagos</id><name>Lagos</name></timezone><timezone><id>Africa/Kigali</id><name>Kigali</name></timezone><timezone><id>Africa/Douala</id><name>Douala</name></timezone><timezone><id>Africa/Asmara</id><name>Asmara</name></timezone><timezone><id>Africa/Malabo</id><name>Malabo</name></timezone><timezone><id>Africa/Lusaka</id><name>Lusaka</name></timezone><timezone><id>Africa/Kinshasa</id><name>Kinshasa</name></timezone><timezone><id>Africa/El_Aaiun</id><name>El Aaiun</name></timezone><timezone><id>Africa/Ceuta</id><name>Ceuta</name></timezone><timezone><id>Africa/Nouakchott</id><name>Nouakchott</name></timezone><timezone><id>Africa/Lubumbashi</id><name>Lubumbashi</name></timezone><timezone><id>Africa/Dar_es_Salaam</id><name>Dar es Salaam</name></timezone><timezone><id>Africa/Dakar</id><name>Dakar</name></timezone><timezone><id>Indian/Reunion</id><name>Reunion</name></timezone><timezone><id>Africa/Ndjamena</id><name>Ndjamena</name></timezone><timezone><id>Africa/Mbabane</id><name>Mbabane</name></timezone><timezone><id>Africa/Khartoum</id><name>Khartoum</name></timezone><timezone><id>Africa/Addis_Ababa</id><name>Addis Ababa</name></timezone><timezone><id>Africa/Ouagadougou</id><name>Ouagadougou</name></timezone><timezone><id>Africa/Harare</id><name>Harare</name></timezone><timezone><id>Africa/Bissau</id><name>Bissau</name></timezone><timezone><id>Africa/Bangui</id><name>Bangui</name></timezone><timezone><id>Africa/Bamako</id><name>Bamako</name></timezone><timezone><id>Africa/Tunis</id><name>Tunis</name></timezone><timezone><id>Africa/Monrovia</id><name>Monrovia</name></timezone><timezone><id>Africa/Djibouti</id><name>Djibouti</name></timezone><timezone><id>Africa/Brazzaville</id><name>Brazzaville</name></timezone><timezone><id>Africa/Algiers</id><name>Algiers</name></timezone><timezone><id>Africa/Abidjan</id><name>Abidjan</name></timezone><timezone><id>Africa/Porto-Novo</id><name>Porto-Novo</name></timezone><timezone><id>Africa/Nairobi</id><name>Nairobi</name></timezone><timezone><id>Africa/Lome</id><name>Lome</name></timezone><timezone><id>Africa/Gaborone</id><name>Gaborone</name></timezone><timezone><id>Africa/Accra</id><name>Accra</name></timezone><timezone><id>Indian/Antananarivo</id><name>Antananarivo</name></timezone><timezone><id>Africa/Sao_Tome</id><name>Sao Tome</name></timezone><timezone><id>Africa/Libreville</id><name>Libreville</name></timezone><timezone><id>Africa/Freetown</id><name>Freetown</name></timezone><timezone><id>Africa/Bujumbura</id><name>Bujumbura</name></timezone><timezone><id>Africa/Tripoli</id><name>Tripoli</name></timezone><timezone><id>Africa/Niamey</id><name>Niamey</name></timezone><timezone><id>Africa/Mogadishu</id><name>Mogadishu</name></timezone><timezone><id>Africa/Kampala</id><name>Kampala</name></timezone><timezone><id>Africa/Conakry</id><name>Conakry</name></timezone><timezone><id>Africa/Cairo</id><name>Cairo</name></timezone><timezone><id>Africa/Blantyre</id><name>Blantyre</name></timezone></entries></region><region><name>Argentina</name><central>America/Argentina/Buenos_Aires</central><entries type="array"><timezone><id>America/Argentina/San_Juan</id><name>San Juan</name></timezone><timezone><id>America/Argentina/Mendoza</id><name>Mendoza</name></timezone><timezone><id>America/Argentina/La_Rioja</id><name>La Rioja</name></timezone><timezone><id>America/Argentina/Jujuy</id><name>Jujuy</name></timezone><timezone><id>America/Argentina/Buenos_Aires</id><name>Buenos Aires</name></timezone><timezone><id>America/Argentina/Rio_Gallegos</id><name>Rio Gallegos</name></timezone><timezone><id>America/Argentina/Ushuaia</id><name>Ushuaia</name></timezone><timezone><id>America/Argentina/San_Luis</id><name>San Luis</name></timezone><timezone><id>America/Argentina/Cordoba</id><name>Cordoba</name></timezone><timezone><id>America/Argentina/Tucuman</id><name>Tucuman</name></timezone><timezone><id>America/Argentina/Catamarca</id><name>Catamarca</name></timezone></entries></region><region><name>Asia</name><central>Asia/Kolkata</central><entries type="array"><timezone><id>Asia/Yerevan</id><name>Yerevan</name></timezone><timezone><id>Asia/Ulaanbaatar</id><name>Ulan Bator</name></timezone><timezone><id>Asia/Magadan</id><name>Magadan</name></timezone><timezone><id>Asia/Choibalsan</id><name>Choibalsan</name></timezone><timezone><id>Asia/Baghdad</id><name>Baghdad</name></timezone><timezone><id>Mideast/Riyadh87</id><name>Mideast Riyadh87</name></timezone><timezone><id>Asia/Yakutsk</id><name>Yakutsk</name></timezone><timezone><id>Asia/Pontianak</id><name>Pontianak</name></timezone><timezone><id>Mideast/Riyadh88</id><name>Mideast Riyadh88</name></timezone><timezone><id>Asia/Dushanbe</id><name>Dushanbe</name></timezone><timezone><id>Asia/Singapore</id><name>Singapore</name></timezone><timezone><id>Mideast/Riyadh89</id><name>Mideast Riyadh89</name></timezone><timezone><id>Asia/Vientiane</id><name>Vientiane</name></timezone><timezone><id>Asia/Tehran</id><name>Tehran</name></timezone><timezone><id>Asia/Damascus</id><name>Damascus</name></timezone><timezone><id>Asia/Karachi</id><name>Karachi</name></timezone><timezone><id>Asia/Baku</id><name>Baku</name></timezone><timezone><id>Asia/Hong_Kong</id><name>Hongkong</name></timezone><timezone><id>Asia/Sakhalin</id><name>Sakhalin</name></timezone><timezone><id>Asia/Tashkent</id><name>Tashkent</name></timezone><timezone><id>Asia/Qatar</id><name>Qatar</name></timezone><timezone><id>Asia/Seoul</id><name>Seoul</name></timezone><timezone><id>Asia/Harbin</id><name>Harbin</name></timezone><timezone><id>Asia/Oral</id><name>Oral</name></timezone><timezone><id>Asia/Jayapura</id><name>Jayapura</name></timezone><timezone><id>Asia/Beijing</id><name>Beijing</name></timezone><timezone><id>Asia/Shanghai</id><name>Shanghai</name></timezone><timezone><id>Asia/Dubai</id><name>Dubai</name></timezone><timezone><id>Asia/Urumqi</id><name>Urumqi</name></timezone><timezone><id>Asia/Kabul</id><name>Afghanistan</name></timezone><timezone><id>Asia/Bangkok</id><name>Bangkok</name></timezone><timezone><id>Asia/Samarkand</id><name>Samarkand</name></timezone><timezone><id>Asia/Amman</id><name>Amman</name></timezone><timezone><id>Asia/Taipei</id><name>Taipei</name></timezone><timezone><id>Asia/Krasnoyarsk</id><name>Krasnoyarsk</name></timezone><timezone><id>Asia/Vladivostok</id><name>Vladivostok</name></timezone><timezone><id>Asia/Kuching</id><name>Kuching</name></timezone><timezone><id>Asia/Muscat</id><name>Muscat</name></timezone><timezone><id>Asia/Omsk</id><name>Omsk</name></timezone><timezone><id>Asia/Aqtau</id><name>Aqtau</name></timezone><timezone><id>Asia/Rangoon</id><name>Myanmar</name></timezone><timezone><id>Asia/Gaza</id><name>Gaza</name></timezone><timezone><id>Asia/Jerusalem</id><name>Israel</name></timezone><timezone><id>Asia/Chongqing</id><name>Chongqing</name></timezone><timezone><id>Asia/Brunei</id><name>Brunei</name></timezone><timezone><id>Asia/Qyzylorda</id><name>Qyzylorda</name></timezone><timezone><id>Asia/Aqtobe</id><name>Aqtobe</name></timezone><timezone><id>Asia/Kuwait</id><name>Kuwait</name></timezone><timezone><id>Asia/Kamchatka</id><name>Kamchatka</name></timezone><timezone><id>Asia/Colombo</id><name>Colombo</name></timezone><timezone><id>Asia/Riyadh</id><name>Riyadh</name></timezone><timezone><id>Asia/Beirut</id><name>Beirut</name></timezone><timezone><id>Asia/Kashgar</id><name>Kashgar</name></timezone><timezone><id>Asia/Almaty</id><name>Almaty</name></timezone><timezone><id>Asia/Thimphu</id><name>Thimphu</name></timezone><timezone><id>Asia/Manila</id><name>Manila</name></timezone><timezone><id>Asia/Macau</id><name>Macao</name></timezone><timezone><id>Asia/Bishkek</id><name>Bishkek</name></timezone><timezone><id>Asia/Ashgabat</id><name>Ashgabat</name></timezone><timezone><id>Asia/Nicosia</id><name>Nicosia</name></timezone><timezone><id>Asia/Jakarta</id><name>Jakarta</name></timezone><timezone><id>Asia/Makassar</id><name>Makassar</name></timezone><timezone><id>Asia/Phnom_Penh</id><name>Phnom Penh</name></timezone><timezone><id>Asia/Aden</id><name>Aden</name></timezone><timezone><id>Asia/Anadyr</id><name>Anadyr</name></timezone><timezone><id>Asia/Dhaka</id><name>Dhaka</name></timezone><timezone><id>Asia/Kuala_Lumpur</id><name>Kuala Lumpur</name></timezone><timezone><id>Asia/Irkutsk</id><name>Irkutsk</name></timezone><timezone><id>Asia/Tbilisi</id><name>Tbilisi</name></timezone><timezone><id>Asia/Yekaterinburg</id><name>Yekaterinburg</name></timezone><timezone><id>Asia/Tokyo</id><name>Japan</name></timezone><timezone><id>Asia/Katmandu</id><name>Katmandu</name></timezone><timezone><id>Asia/Kolkata</id><name>Kolkata</name></timezone><timezone><id>Asia/Dili</id><name>Dili</name></timezone><timezone><id>Asia/Pyongyang</id><name>Pyongyang</name></timezone><timezone><id>Asia/Hovd</id><name>Hovd</name></timezone><timezone><id>Asia/Novosibirsk</id><name>Novosibirsk</name></timezone><timezone><id>Asia/Ho_Chi_Minh</id><name>Saigon</name></timezone><timezone><id>Asia/Bahrain</id><name>Bahrain</name></timezone></entries></region><region><name>Atlantic</name><central>Atlantic/Madeira</central><entries type="array"><timezone><id>Atlantic/Stanley</id><name>Stanley</name></timezone><timezone><id>Atlantic/St_Helena</id><name>St Helena</name></timezone><timezone><id>Atlantic/Jan_Mayen</id><name>Jan Mayen</name></timezone><timezone><id>America/Miquelon</id><name>Miquelon</name></timezone><timezone><id>Atlantic/Canary</id><name>Canary Islands</name></timezone><timezone><id>Atlantic/Bermuda</id><name>Bermuda</name></timezone><timezone><id>Atlantic/Reykjavik</id><name>Iceland</name></timezone><timezone><id>America/Thule</id><name>Greenland (Thule)</name></timezone><timezone><id>America/Godthab</id><name>Greenland (Nuuk)</name></timezone><timezone><id>Atlantic/Faroe</id><name>Faroe Islands</name></timezone><timezone><id>America/Scoresbysund</id><name>Greenland (Scoresbysund)</name></timezone><timezone><id>Atlantic/Madeira</id><name>Madeira</name></timezone><timezone><id>Atlantic/Azores</id><name>Azores</name></timezone><timezone><id>Atlantic/South_Georgia</id><name>South Georgia</name></timezone><timezone><id>Atlantic/Cape_Verde</id><name>Cape Verde</name></timezone><timezone><id>America/Danmarkshavn</id><name>Greenland (Danmarkshavn)</name></timezone></entries></region><region><name>Australia</name><central>Australia/Sydney</central><entries type="array"><timezone><id>Australia/Sydney</id><name>New South Wales (Sydney)</name></timezone><timezone><id>Australia/Lindeman</id><name>Lindeman</name></timezone><timezone><id>Australia/Darwin</id><name>Northern Territory (Darwin)</name></timezone><timezone><id>Australia/Adelaide</id><name>South Australia (Adelaide)</name></timezone><timezone><id>Australia/Hobart</id><name>Tasmania (Hobart)</name></timezone><timezone><id>Australia/Eucla</id><name>Eucla</name></timezone><timezone><id>Australia/Broken_Hill</id><name>New South Wales (Broken Hill)</name></timezone><timezone><id>Australia/Currie</id><name>Tasmania (Currie)</name></timezone><timezone><id>Australia/Perth</id><name>Western Australia (Perth)</name></timezone><timezone><id>Australia/Melbourne</id><name>Victoria (Melbourne)</name></timezone><timezone><id>Australia/Lord_Howe</id><name>Lord Howe Island</name></timezone><timezone><id>Australia/Brisbane</id><name>Queensland (Brisbane)</name></timezone></entries></region><region><name>Brazil</name><central>America/Sao_Paulo</central><entries type="array"><timezone><id>America/Porto_Velho</id><name>Porto Velho</name></timezone><timezone><id>America/Eirunepe</id><name>Eirunepe</name></timezone><timezone><id>America/Bahia</id><name>Bahia</name></timezone><timezone><id>America/Noronha</id><name>Fernando de Noronha</name></timezone><timezone><id>America/Cuiaba</id><name>Cuiaba</name></timezone><timezone><id>America/Campo_Grande</id><name>Campo Grande</name></timezone><timezone><id>America/Boa_Vista</id><name>Boa Vista</name></timezone><timezone><id>America/Recife</id><name>Recife</name></timezone><timezone><id>America/Manaus</id><name>Manaus</name></timezone><timezone><id>America/Araguaina</id><name>Araguaina</name></timezone><timezone><id>America/Maceio</id><name>Maceio</name></timezone><timezone><id>America/Sao_Paulo</id><name>Sao Paulo</name></timezone><timezone><id>America/Rio_Branco</id><name>Rio Branco</name></timezone><timezone><id>America/Belem</id><name>Belem</name></timezone><timezone><id>America/Fortaleza</id><name>Fortaleza</name></timezone></entries></region><region><name>Canada</name><central>America/Winnipeg</central><entries type="array"><timezone><id>America/Regina</id><name>Saskatchewan (Regina)</name></timezone><timezone><id>America/Rankin_Inlet</id><name>Rankin Inlet</name></timezone><timezone><id>America/Thunder_Bay</id><name>Thunder Bay</name></timezone><timezone><id>America/Resolute</id><name>Resolute</name></timezone><timezone><id>America/Goose_Bay</id><name>Goose Bay</name></timezone><timezone><id>America/Dawson_Creek</id><name>Dawson Creek</name></timezone><timezone><id>America/Atikokan</id><name>Atikokan</name></timezone><timezone><id>America/Whitehorse</id><name>Yukon (Whitehorse)</name></timezone><timezone><id>America/Swift_Current</id><name>Swift Current</name></timezone><timezone><id>America/St_Johns</id><name>Newfoundland (St Johns)</name></timezone><timezone><id>America/Iqaluit</id><name>Iqaluit</name></timezone><timezone><id>America/Blanc-Sablon</id><name>Blanc-Sablon</name></timezone><timezone><id>America/Glace_Bay</id><name>Glace Bay</name></timezone><timezone><id>America/Yellowknife</id><name>Yellowknife</name></timezone><timezone><id>America/Inuvik</id><name>Inuvik</name></timezone><timezone><id>America/Dawson</id><name>Dawson</name></timezone><timezone><id>America/Rainy_River</id><name>Rainy River</name></timezone><timezone><id>America/Pangnirtung</id><name>Pangnirtung</name></timezone><timezone><id>America/Nipigon</id><name>Nipigon</name></timezone><timezone><id>America/Toronto</id><name>Eastern (Toronto)</name></timezone><timezone><id>America/Montreal</id><name>Montreal</name></timezone><timezone><id>America/Moncton</id><name>Moncton</name></timezone><timezone><id>America/Edmonton</id><name>Mountain (Edmonton)</name></timezone><timezone><id>America/Cambridge_Bay</id><name>Cambridge Bay</name></timezone><timezone><id>America/Winnipeg</id><name>Central (Winnipeg)</name></timezone><timezone><id>America/Vancouver</id><name>Pacific (Vancouver)</name></timezone><timezone><id>America/Halifax</id><name>Atlantic (Halifax)</name></timezone></entries></region><region><name>Central and South America</name><central>America/La_Paz</central><entries type="array"><timezone><id>Atlantic/Stanley</id><name>Stanley</name></timezone><timezone><id>America/Montevideo</id><name>Uruguay</name></timezone><timezone><id>America/Martinique</id><name>Martinique</name></timezone><timezone><id>America/Managua</id><name>Managua</name></timezone><timezone><id>America/La_Paz</id><name>La Paz</name></timezone><timezone><id>America/Grenada</id><name>Grenada</name></timezone><timezone><id>America/Cayman</id><name>Cayman Islands</name></timezone><timezone><id>America/Caracas</id><name>Caracas</name></timezone><timezone><id>America/Anguilla</id><name>Anguilla</name></timezone><timezone><id>America/St_Lucia</id><name>Saint Lucia</name></timezone><timezone><id>America/Costa_Rica</id><name>Costa Rica</name></timezone><timezone><id>America/Havana</id><name>Havana</name></timezone><timezone><id>America/Aruba</id><name>Aruba</name></timezone><timezone><id>America/St_Thomas</id><name>St Thomas</name></timezone><timezone><id>America/Port-au-Prince</id><name>Port-au-Prince</name></timezone><timezone><id>America/Guyana</id><name>Guyana</name></timezone><timezone><id>America/Guatemala</id><name>Guatemala</name></timezone><timezone><id>America/El_Salvador</id><name>El Salvador</name></timezone><timezone><id>America/Dominica</id><name>Dominica</name></timezone><timezone><id>America/Paramaribo</id><name>Paramaribo</name></timezone><timezone><id>America/Panama</id><name>Panama</name></timezone><timezone><id>America/Guayaquil</id><name>Guayaquil</name></timezone><timezone><id>America/Grand_Turk</id><name>Grand Turk</name></timezone><timezone><id>America/Bogota</id><name>Bogota</name></timezone><timezone><id>America/Belize</id><name>Belize</name></timezone><timezone><id>America/St_Vincent</id><name>St Vincent</name></timezone><timezone><id>America/St_Kitts</id><name>Saint Kitts and Nevis</name></timezone><timezone><id>America/Curacao</id><name>Curacao</name></timezone><timezone><id>Pacific/Galapagos</id><name>Galapagos</name></timezone><timezone><id>America/Puerto_Rico</id><name>Puerto Rico</name></timezone><timezone><id>America/Montserrat</id><name>Montserrat</name></timezone><timezone><id>America/Jamaica</id><name>Jamaica</name></timezone><timezone><id>America/Barbados</id><name>Barbados</name></timezone><timezone><id>America/Antigua</id><name>Antigua</name></timezone><timezone><id>America/Nassau</id><name>Nassau</name></timezone><timezone><id>America/Asuncion</id><name>Asuncion</name></timezone><timezone><id>Pacific/Easter</id><name>Easter Island</name></timezone><timezone><id>America/Tegucigalpa</id><name>Tegucigalpa</name></timezone><timezone><id>America/Lima</id><name>Lima</name></timezone><timezone><id>America/Guadeloupe</id><name>Guadeloupe</name></timezone><timezone><id>America/Tortola</id><name>Tortola</name></timezone><timezone><id>America/Santo_Domingo</id><name>Santo Domingo</name></timezone><timezone><id>America/Santiago</id><name>Chile Continental</name></timezone><timezone><id>America/Port_of_Spain</id><name>Port of Spain</name></timezone><timezone><id>America/Cayenne</id><name>Cayenne</name></timezone></entries></region><region><name>Etc</name><central>Etc/GMT</central><entries type="array"><timezone><id>Etc/Zulu</id><name>Zulu</name></timezone><timezone><id>Etc/UTC</id><name>UTC</name></timezone><timezone><id>Etc/Greenwich</id><name>Greenwich</name></timezone><timezone><id>Etc/GMT-9</id><name>GMT-9</name></timezone><timezone><id>Etc/GMT-14</id><name>GMT-14</name></timezone><timezone><id>Etc/GMT+7</id><name>GMT+7</name></timezone><timezone><id>Etc/UCT</id><name>UCT</name></timezone><timezone><id>Etc/GMT-0</id><name>GMT-0</name></timezone><timezone><id>Etc/GMT+8</id><name>GMT+8</name></timezone><timezone><id>Etc/GMT-1</id><name>GMT-1</name></timezone><timezone><id>Etc/GMT+9</id><name>GMT+9</name></timezone><timezone><id>Etc/GMT-2</id><name>GMT-2</name></timezone><timezone><id>Etc/GMT+0</id><name>GMT+0</name></timezone><timezone><id>Etc/GMT-3</id><name>GMT-3</name></timezone><timezone><id>Etc/GMT+10</id><name>GMT+10</name></timezone><timezone><id>Etc/GMT+1</id><name>GMT+1</name></timezone><timezone><id>Etc/GMT-4</id><name>GMT-4</name></timezone><timezone><id>Etc/GMT+2</id><name>GMT+2</name></timezone><timezone><id>Etc/GMT+11</id><name>GMT+11</name></timezone><timezone><id>Etc/Universal</id><name>Universal</name></timezone><timezone><id>Etc/GMT0</id><name>GMT0</name></timezone><timezone><id>Etc/GMT-5</id><name>GMT-5</name></timezone><timezone><id>Etc/GMT-10</id><name>GMT-10</name></timezone><timezone><id>Etc/GMT+3</id><name>GMT+3</name></timezone><timezone><id>Etc/GMT+12</id><name>GMT+12</name></timezone><timezone><id>Etc/GMT-6</id><name>GMT-6</name></timezone><timezone><id>Etc/GMT-11</id><name>GMT-11</name></timezone><timezone><id>Etc/GMT+4</id><name>GMT+4</name></timezone><timezone><id>Etc/GMT-7</id><name>GMT-7</name></timezone><timezone><id>Etc/GMT-12</id><name>GMT-12</name></timezone><timezone><id>Etc/GMT+5</id><name>GMT+5</name></timezone><timezone><id>Etc/GMT-8</id><name>GMT-8</name></timezone><timezone><id>Etc/GMT-13</id><name>GMT-13</name></timezone><timezone><id>Etc/GMT+6</id><name>GMT+6</name></timezone><timezone><id>Etc/GMT</id><name>GMT</name></timezone></entries></region><region><name>Europe</name><central>Europe/Prague</central><entries type="array"><timezone><id>Europe/Uzhgorod</id><name>Uzhgorod</name></timezone><timezone><id>Europe/Moscow</id><name>Russia (Moscow)</name></timezone><timezone><id>Europe/Jersey</id><name>Jersey</name></timezone><timezone><id>Europe/Brussels</id><name>Belgium</name></timezone><timezone><id>Europe/Amsterdam</id><name>Netherlands</name></timezone><timezone><id>America/Miquelon</id><name>Miquelon</name></timezone><timezone><id>Europe/Zaporozhye</id><name>Ukraine (Zaporozhye)</name></timezone><timezone><id>Europe/Paris</id><name>France</name></timezone><timezone><id>Europe/Oslo</id><name>Norway</name></timezone><timezone><id>Europe/Malta</id><name>Malta</name></timezone><timezone><id>Europe/Helsinki</id><name>Finland</name></timezone><timezone><id>Europe/Athens</id><name>Greece</name></timezone><timezone><id>Atlantic/Canary</id><name>Canary Islands</name></timezone><timezone><id>Europe/Skopje</id><name>Macedonia</name></timezone><timezone><id>Europe/Monaco</id><name>Monaco</name></timezone><timezone><id>Atlantic/Reykjavik</id><name>Iceland</name></timezone><timezone><id>Europe/San_Marino</id><name>San Marino</name></timezone><timezone><id>Europe/Rome</id><name>Italy</name></timezone><timezone><id>Europe/Lisbon</id><name>Portugal</name></timezone><timezone><id>Europe/Istanbul</id><name>Turkey</name></timezone><timezone><id>Europe/Dublin</id><name>Ireland</name></timezone><timezone><id>Europe/Bratislava</id><name>Slovakia</name></timezone><timezone><id>Europe/Berlin</id><name>Germany</name></timezone><timezone><id>Europe/Madrid</id><name>Spain</name></timezone><timezone><id>Europe/Isle_of_Man</id><name>Isle of Man</name></timezone><timezone><id>Europe/Guernsey</id><name>Guernsey</name></timezone><timezone><id>Europe/Copenhagen</id><name>Denmark</name></timezone><timezone><id>Europe/Zurich</id><name>Switzerland</name></timezone><timezone><id>Europe/Zagreb</id><name>Croatia</name></timezone><timezone><id>Europe/Tallinn</id><name>Estonia</name></timezone><timezone><id>Europe/Kiev</id><name>Ukraine (Kiev)</name></timezone><timezone><id>Europe/Warsaw</id><name>Poland</name></timezone><timezone><id>Europe/Vilnius</id><name>Lithuania</name></timezone><timezone><id>Europe/Vatican</id><name>Vatican</name></timezone><timezone><id>Europe/Prague</id><name>Czech Republic</name></timezone><timezone><id>Europe/Mariehamn</id><name>Aaland Islands</name></timezone><timezone><id>Europe/Kaliningrad</id><name>Russia (Kaliningrad)</name></timezone><timezone><id>Europe/Gibraltar</id><name>Gibraltar</name></timezone><timezone><id>Europe/Belgrade</id><name>Serbia</name></timezone><timezone><id>Europe/Vienna</id><name>Austria</name></timezone><timezone><id>Europe/Vaduz</id><name>Liechtenstein</name></timezone><timezone><id>Europe/Luxembourg</id><name>Luxembourg</name></timezone><timezone><id>Europe/Ljubljana</id><name>Slovenia</name></timezone><timezone><id>Europe/Andorra</id><name>Andorra</name></timezone><timezone><id>Atlantic/Azores</id><name>Azores</name></timezone><timezone><id>Europe/Simferopol</id><name>Ukraine (Simferopol)</name></timezone><timezone><id>Europe/Minsk</id><name>Belarus</name></timezone><timezone><id>Europe/London</id><name>United Kingdom</name></timezone><timezone><id>Europe/Bucharest</id><name>Romania</name></timezone><timezone><id>Europe/Volgograd</id><name>Russia (Volgograd)</name></timezone><timezone><id>Europe/Tirane</id><name>Albania</name></timezone><timezone><id>Europe/Stockholm</id><name>Sweden</name></timezone><timezone><id>Europe/Sofia</id><name>Bulgaria</name></timezone><timezone><id>Europe/Sarajevo</id><name>Bosnia &amp; Herzegovina</name></timezone><timezone><id>Europe/Samara</id><name>Russia (Samara)</name></timezone><timezone><id>Europe/Riga</id><name>Latvia</name></timezone><timezone><id>Europe/Podgorica</id><name>Montenegro</name></timezone><timezone><id>Europe/Chisinau</id><name>Moldova</name></timezone><timezone><id>Europe/Budapest</id><name>Hungary</name></timezone></entries></region><region><name>Global</name><central>America/Godthab</central><entries type="array"><timezone><id>NZ</id><name>NZ</name></timezone><timezone><id>GMT+0</id><name>GMT+0</name></timezone><timezone><id>GMT0</id><name>GMT0</name></timezone><timezone><id>Antarctica/Syowa</id><name>Antarctica (Syowa)</name></timezone><timezone><id>Antarctica/Mawson</id><name>Antarctica (Mawson)</name></timezone><timezone><id>Navajo</id><name>Navajo</name></timezone><timezone><id>MST</id><name>MST</name></timezone><timezone><id>GMT</id><name>GMT</name></timezone><timezone><id>CST6CDT</id><name>CST6CDT</name></timezone><timezone><id>Arctic/Longyearbyen</id><name>Arctic Longyearbyen</name></timezone><timezone><id>Universal</id><name>Universal</name></timezone><timezone><id>UTC</id><name>UTC</name></timezone><timezone><id>Antarctica/Casey</id><name>Antarctica (Casey)</name></timezone><timezone><id>PST8PDT</id><name>PST8PDT</name></timezone><timezone><id>NZ-CHAT</id><name>NZ-CHAT</name></timezone><timezone><id>America/Thule</id><name>Greenland (Thule)</name></timezone><timezone><id>America/Godthab</id><name>Greenland (Nuuk)</name></timezone><timezone><id>Zulu</id><name>Zulu</name></timezone><timezone><id>WET</id><name>WET</name></timezone><timezone><id>W-SU</id><name>W-SU</name></timezone><timezone><id>UCT</id><name>UCT</name></timezone><timezone><id>MET</id><name>MET</name></timezone><timezone><id>Greenwich</id><name>Greenwich</name></timezone><timezone><id>EST</id><name>EST</name></timezone><timezone><id>America/Scoresbysund</id><name>Greenland (Scoresbysund)</name></timezone><timezone><id>CET</id><name>CET</name></timezone><timezone><id>Antarctica/Vostok</id><name>Antarctica (Vostok)</name></timezone><timezone><id>Antarctica/South_Pole</id><name>Antarctica (South Pole)</name></timezone><timezone><id>Antarctica/Rothera</id><name>Antarctica (Rothera)</name></timezone><timezone><id>Antarctica/Palmer</id><name>Antarctica (Palmer)</name></timezone><timezone><id>Antarctica/McMurdo</id><name>Antarctica (McMurdo)</name></timezone><timezone><id>MST7MDT</id><name>MST7MDT</name></timezone><timezone><id>HST</id><name>HST</name></timezone><timezone><id>EET</id><name>EET</name></timezone><timezone><id>Antarctica/DumontDUrville</id><name>Antarctica (DumontDUrville)</name></timezone><timezone><id>Antarctica/Davis</id><name>Antarctica (Davis)</name></timezone><timezone><id>America/Danmarkshavn</id><name>Greenland (Danmarkshavn)</name></timezone><timezone><id>GMT-0</id><name>GMT-0</name></timezone><timezone><id>EST5EDT</id><name>EST5EDT</name></timezone></entries></region><region><name>Indian Ocean</name><central>Indian/Maldives</central><entries type="array"><timezone><id>Indian/Maldives</id><name>Maldives</name></timezone><timezone><id>Indian/Mauritius</id><name>Mauritius</name></timezone><timezone><id>Indian/Reunion</id><name>Reunion</name></timezone><timezone><id>Indian/Comoro</id><name>Comoro</name></timezone><timezone><id>Indian/Cocos</id><name>Cocos Islands</name></timezone><timezone><id>Indian/Mayotte</id><name>Mayotte</name></timezone><timezone><id>Indian/Mahe</id><name>Mahe</name></timezone><timezone><id>Indian/Chagos</id><name>Chagos</name></timezone><timezone><id>Indian/Kerguelen</id><name>Kerguelen</name></timezone><timezone><id>Indian/Christmas</id><name>Christmas Island</name></timezone></entries></region><region><name>Mexico</name><central>America/Mexico_City</central><entries type="array"><timezone><id>America/Cancun</id><name>Cancun</name></timezone><timezone><id>America/Mazatlan</id><name>Mazatlan</name></timezone><timezone><id>America/Hermosillo</id><name>Hermosillo</name></timezone><timezone><id>America/Merida</id><name>Merida</name></timezone><timezone><id>America/Monterrey</id><name>Monterrey</name></timezone><timezone><id>America/Chihuahua</id><name>Chihuahua</name></timezone><timezone><id>America/Mexico_City</id><name>Mexico City</name></timezone><timezone><id>America/Tijuana</id><name>Tijuana</name></timezone></entries></region><region><name>Pacific</name><central>Pacific/Tahiti</central><entries type="array"><timezone><id>Pacific/Port_Moresby</id><name>Port_Moresby</name></timezone><timezone><id>Pacific/Palau</id><name>Palau</name></timezone><timezone><id>Pacific/Nauru</id><name>Nauru</name></timezone><timezone><id>Pacific/Guam</id><name>Guam</name></timezone><timezone><id>Pacific/Efate</id><name>Efate</name></timezone><timezone><id>Pacific/Gambier</id><name>Gambier</name></timezone><timezone><id>Pacific/Funafuti</id><name>Funafuti</name></timezone><timezone><id>Pacific/Fiji</id><name>Fiji</name></timezone><timezone><id>Pacific/Kosrae</id><name>Kosrae</name></timezone><timezone><id>Pacific/Chatham</id><name>Chatham</name></timezone><timezone><id>Pacific/Apia</id><name>Apia</name></timezone><timezone><id>Pacific/Wake</id><name>Wake</name></timezone><timezone><id>Pacific/Pago_Pago</id><name>Samoa</name></timezone><timezone><id>Pacific/Wallis</id><name>Wallis</name></timezone><timezone><id>Pacific/Ponape</id><name>Pohnpei</name></timezone><timezone><id>Pacific/Auckland</id><name>New Zealand</name></timezone><timezone><id>Pacific/Tongatapu</id><name>Tongatapu</name></timezone><timezone><id>Pacific/Tarawa</id><name>Tarawa</name></timezone><timezone><id>Pacific/Kiritimati</id><name>Kiritimati</name></timezone><timezone><id>Pacific/Guadalcanal</id><name>Guadalcanal</name></timezone><timezone><id>Pacific/Truk</id><name>Chuuk</name></timezone><timezone><id>Pacific/Midway</id><name>Midway</name></timezone><timezone><id>Pacific/Majuro</id><name>Majuro</name></timezone><timezone><id>Pacific/Kwajalein</id><name>Kwajalein</name></timezone><timezone><id>Pacific/Rarotonga</id><name>Rarotonga</name></timezone><timezone><id>Pacific/Noumea</id><name>Noumea</name></timezone><timezone><id>Pacific/Norfolk</id><name>Norfolk</name></timezone><timezone><id>Pacific/Niue</id><name>Niue</name></timezone><timezone><id>Pacific/Enderbury</id><name>Enderbury</name></timezone><timezone><id>Pacific/Tahiti</id><name>Tahiti</name></timezone><timezone><id>Pacific/Pitcairn</id><name>Pitcairn</name></timezone><timezone><id>Pacific/Saipan</id><name>Saipan</name></timezone><timezone><id>Pacific/Marquesas</id><name>Marquesas</name></timezone><timezone><id>Pacific/Johnston</id><name>Johnston</name></timezone><timezone><id>Pacific/Fakaofo</id><name>Fakaofo</name></timezone><timezone><id>Pacific/Dili</id><name>Dili</name></timezone></entries></region><region><name>Russia</name><central>Asia/Novosibirsk</central><entries type="array"><timezone><id>Europe/Moscow</id><name>Moscow</name></timezone><timezone><id>Asia/Yekaterinburg</id><name>Yekaterinburg</name></timezone><timezone><id>Asia/Sakhalin</id><name>Sakhalin</name></timezone><timezone><id>Asia/Kamchatka</id><name>Kamchatka</name></timezone><timezone><id>Asia/Irkutsk</id><name>Irkutsk</name></timezone><timezone><id>Asia/Yakutsk</id><name>Yakutsk</name></timezone><timezone><id>Asia/Vladivostok</id><name>Vladivostok</name></timezone><timezone><id>Asia/Anadyr</id><name>Anadyr</name></timezone><timezone><id>Asia/Omsk</id><name>Omsk</name></timezone><timezone><id>Europe/Kaliningrad</id><name>Kaliningrad</name></timezone><timezone><id>Asia/Novosibirsk</id><name>Novosibirsk</name></timezone><timezone><id>Asia/Krasnoyarsk</id><name>Krasnoyarsk</name></timezone><timezone><id>Asia/Magadan</id><name>Magadan</name></timezone><timezone><id>Europe/Volgograd</id><name>Volgograd</name></timezone><timezone><id>Europe/Samara</id><name>Samara</name></timezone></entries></region><region><name>USA</name><central>America/Chicago</central><entries type="array"><timezone><id>Pacific/Honolulu</id><name>Hawaii (Honolulu)</name></timezone><timezone><id>America/Chicago</id><name>Central (Chicago)</name></timezone><timezone><id>America/Anchorage</id><name>Alaska (Anchorage)</name></timezone><timezone><id>America/Kentucky/Monticello</id><name>Kentucky (Monticello)</name></timezone><timezone><id>America/Juneau</id><name>Juneau</name></timezone><timezone><id>America/Indiana/Petersburg</id><name>Indiana (Petersburg)</name></timezone><timezone><id>America/Indiana/Indianapolis</id><name>East Indiana (Indianapolis)</name></timezone><timezone><id>America/Shiprock</id><name>Shiprock</name></timezone><timezone><id>America/Los_Angeles</id><name>Pacific (Los Angeles)</name></timezone><timezone><id>America/Indiana/Marengo</id><name>Indiana (Marengo)</name></timezone><timezone><id>Pacific/Pago_Pago</id><name>Samoa (Pago Pago)</name></timezone><timezone><id>America/St_Thomas</id><name>Virgin Islands (St Thomas)</name></timezone><timezone><id>America/North_Dakota/New_Salem</id><name>North Dakota (New Salem)</name></timezone><timezone><id>America/Indiana/Vevay</id><name>Indiana (Vevay)</name></timezone><timezone><id>America/Denver</id><name>Mountain (Denver)</name></timezone><timezone><id>America/Menominee</id><name>Menominee</name></timezone><timezone><id>America/Indiana/Winamac</id><name>Indiana (Winamac)</name></timezone><timezone><id>America/Boise</id><name>Boise</name></timezone><timezone><id>America/Phoenix</id><name>Arizona (Phoenix)</name></timezone><timezone><id>America/Indiana/Vincennes</id><name>Indiana (Vincennes)</name></timezone><timezone><id>America/Adak</id><name>Aleutian (Adak)</name></timezone><timezone><id>America/New_York</id><name>Eastern (New York)</name></timezone><timezone><id>America/Detroit</id><name>Michigan (Detroit)</name></timezone><timezone><id>America/Puerto_Rico</id><name>Puerto Rico</name></timezone><timezone><id>America/Nome</id><name>Nome</name></timezone><timezone><id>America/Kentucky/Louisville</id><name>Kentucky (Louisville)</name></timezone><timezone><id>America/Yakutat</id><name>Yakutat</name></timezone><timezone><id>America/North_Dakota/Center</id><name>North Dakota (Center)</name></timezone><timezone><id>America/Indiana/Knox</id><name>Indiana Starke (Knox)</name></timezone><timezone><id>America/Indiana/Tell_City</id><name>Indiana (Tell City)</name></timezone></entries></region></timezones></systemtime>
EOX
    ret["systemtime"].to_xml(:root => "systemtime")

  end

  post '/time.xml' do
    time = {"time" => "09:12:16", "date" => "20/08/2009", "timezone" => "Europe/Berlin", "utcstatus" => "UTC"}
    time.to_xml(:root => "systemtime")
  end

  get '/patch.xml' do
    ret = Hash.from_xml <<EOX
<patches type="array">
  <patch_update>
    <id>462</id>
    <resolvable_id type="integer">462</resolvable_id>
    <kind>important</kind>
    <name>softwaremgmt</name>
    <arch>noarch</arch>
    <repo>openSUSE-11.0-Updates</repo>
    <summary>Various fixes for the software management stack</summary>
  </patch_update>
  <patch_update>
    <id>463</id>
    <resolvable_id type="integer">463</resolvable_id>
    <kind>security</kind>
    <name>softwaremgmt security</name>
    <arch>noarch</arch>
    <repo>openSUSE-11.0-Updates</repo>
    <summary>Various fixes for the software management stack</summary>
  </patch_update>
  <patch_update>
    <id>464</id>
    <resolvable_id type="integer">464</resolvable_id>
    <kind>optional</kind>
    <name>vim</name>
    <arch>noarch</arch>
    <repo>openSUSE-11.0-Updates</repo>
    <summary>vim nicer look and feel</summary>
  </patch_update>
</patches>
EOX
    ret["patches"].to_xml(:root => "patches")
  end

  get '/status.xml' do
    ret = Hash.from_xml <<EOX
<status>
  <df>
    <df-suse-schubi>
      <free>
        <T_1250774820>1.0766101709e+11</T_1250774820>
        <T_1250774710>1.0766132838e+11</T_1250774710>
        <T_1250774600>1.0764546867e+11</T_1250774600>
        <T_1250774590>1.0764533760e+11</T_1250774590>
        <T_1250774810>1.0766189363e+11</T_1250774810>
        <T_1250774700>1.0766363034e+11</T_1250774700>
        <T_1250774800>1.0766028800e+11</T_1250774800>
        <T_1250774690>1.0766562099e+11</T_1250774690>
        <T_1250774580>1.0764742656e+11</T_1250774580>
        <T_1250774790>1.0766360576e+11</T_1250774790>
        <T_1250774680>1.0766526054e+11</T_1250774680>
        <T_1250774570>1.0764863078e+11</T_1250774570>
        <T_1250774780>1.0766278656e+11</T_1250774780>
        <T_1250774670>1.0766553088e+11</T_1250774670>
        <T_1250774560>1.0764886016e+11</T_1250774560>
        <T_1250774770>1.0766354842e+11</T_1250774770>
        <T_1250774660>1.0766514586e+11</T_1250774660>
        <T_1250774550>1.0765020365e+11</T_1250774550>
        <T_1250774760>1.0766349926e+11</T_1250774760>
        <T_1250774650>1.0766512947e+11</T_1250774650>
        <T_1250774540>1.0765167821e+11</T_1250774540>
        <T_1250774750>1.0766503936e+11</T_1250774750>
        <T_1250774640>1.0766453965e+11</T_1250774640>
        <T_1250774530>1.0765232538e+11</T_1250774530>
        <T_1250774740>1.0767243674e+11</T_1250774740>
        <T_1250774630>1.0766330266e+11</T_1250774630>
        <limit>
          <maximum type="boolean">false</maximum>
          <value type="float">217989632000.0</value>
        </limit>
        <T_1250774730>1.0766376141e+11</T_1250774730>
        <T_1250774620>1.0765416038e+11</T_1250774620>
        <T_1250774830>1.0766434304e+11</T_1250774830>
        <T_1250774720>1.0766377779e+11</T_1250774720>
        <T_1250774610>1.0765327565e+11</T_1250774610>
      </free>
      <used>
        <T_1250774820>7.8053822464e+11</T_1250774820>
        <T_1250774710>7.8053791334e+11</T_1250774710>
        <T_1250774600>7.8055377306e+11</T_1250774600>
        <T_1250774590>7.8055390413e+11</T_1250774590>
        <T_1250774810>7.8053734810e+11</T_1250774810>
        <T_1250774700>7.8053561139e+11</T_1250774700>
        <T_1250774800>7.8053895373e+11</T_1250774800>
        <T_1250774690>7.8053362074e+11</T_1250774690>
        <T_1250774580>7.8055181517e+11</T_1250774580>
        <T_1250774790>7.8053563597e+11</T_1250774790>
        <T_1250774680>7.8053398118e+11</T_1250774680>
        <T_1250774570>7.8055061094e+11</T_1250774570>
        <T_1250774780>7.8053645517e+11</T_1250774780>
        <T_1250774670>7.8053371085e+11</T_1250774670>
        <T_1250774560>7.8055038157e+11</T_1250774560>
        <T_1250774770>7.8053569331e+11</T_1250774770>
        <T_1250774660>7.8053409587e+11</T_1250774660>
        <T_1250774550>7.8054903808e+11</T_1250774550>
        <T_1250774760>7.8053574246e+11</T_1250774760>
        <T_1250774650>7.8053411226e+11</T_1250774650>
        <T_1250774540>7.8054756352e+11</T_1250774540>
        <T_1250774750>7.8053420237e+11</T_1250774750>
        <T_1250774640>7.8053470208e+11</T_1250774640>
        <T_1250774530>7.8054691635e+11</T_1250774530>
        <T_1250774740>7.8052680499e+11</T_1250774740>
        <T_1250774630>7.8053593907e+11</T_1250774630>
        <T_1250774730>7.8053548032e+11</T_1250774730>
        <T_1250774620>7.8054508134e+11</T_1250774620>
        <T_1250774830>7.8053489869e+11</T_1250774830>
        <T_1250774720>7.8053546394e+11</T_1250774720>
        <T_1250774610>7.8054596608e+11</T_1250774610>
      </used>
    </df-suse-schubi>
    <df-mounts-built>
      <free>
        <T_1250774820>2.9857849344e+10</T_1250774820>
        <T_1250774710>2.9856858112e+10</T_1250774710>
        <T_1250774810>2.9856915456e+10</T_1250774810>
        <T_1250774700>2.9857292288e+10</T_1250774700>
        <T_1250774800>2.9861068800e+10</T_1250774800>
        <T_1250774690>2.9856849920e+10</T_1250774690>
        <T_1250774790>2.9861158912e+10</T_1250774790>
        <T_1250774780>2.9864992768e+10</T_1250774780>
        <T_1250774770>2.9856841728e+10</T_1250774770>
        <T_1250774760>2.9856841728e+10</T_1250774760>
        <T_1250774750>2.9856866304e+10</T_1250774750>
        <T_1250774740>2.9856841728e+10</T_1250774740>
        <T_1250774730>2.9856849920e+10</T_1250774730>
        <T_1250774830>2.9857357824e+10</T_1250774830>
        <T_1250774720>2.9856849920e+10</T_1250774720>
      </free>
      <used>
        <T_1250774820>7.6439347200e+10</T_1250774820>
        <T_1250774710>7.6440338432e+10</T_1250774710>
        <T_1250774810>7.6440281088e+10</T_1250774810>
        <T_1250774700>7.6439904256e+10</T_1250774700>
        <T_1250774800>7.6436127744e+10</T_1250774800>
        <T_1250774690>7.6440346624e+10</T_1250774690>
        <T_1250774790>7.6436037632e+10</T_1250774790>
        <T_1250774780>7.6432203776e+10</T_1250774780>
        <T_1250774770>7.6440354816e+10</T_1250774770>
        <T_1250774760>7.6440354816e+10</T_1250774760>
        <T_1250774750>7.6440330240e+10</T_1250774750>
        <T_1250774740>7.6440354816e+10</T_1250774740>
        <T_1250774730>7.6440346624e+10</T_1250774730>
        <T_1250774830>7.6439838720e+10</T_1250774830>
        <T_1250774720>7.6440346624e+10</T_1250774720>
      </used>
    </df-mounts-built>
    <df-windows-C>
      <free>
        <T_1250774820>9.1551825920e+10</T_1250774820>
        <T_1250774710>9.1551825920e+10</T_1250774710>
        <T_1250774600>9.1551825920e+10</T_1250774600>
        <T_1250774590>9.1551825920e+10</T_1250774590>
        <T_1250774810>9.1551825920e+10</T_1250774810>
        <T_1250774700>9.1551825920e+10</T_1250774700>
        <T_1250774800>9.1551825920e+10</T_1250774800>
        <T_1250774690>9.1551825920e+10</T_1250774690>
        <T_1250774580>9.1551825920e+10</T_1250774580>
        <T_1250774790>9.1551825920e+10</T_1250774790>
        <T_1250774680>9.1551825920e+10</T_1250774680>
        <T_1250774570>9.1551825920e+10</T_1250774570>
        <T_1250774780>9.1551825920e+10</T_1250774780>
        <T_1250774670>9.1551825920e+10</T_1250774670>
        <T_1250774560>9.1551825920e+10</T_1250774560>
        <T_1250774770>9.1551825920e+10</T_1250774770>
        <T_1250774660>9.1551825920e+10</T_1250774660>
        <T_1250774550>9.1551825920e+10</T_1250774550>
        <T_1250774760>9.1551825920e+10</T_1250774760>
        <T_1250774650>9.1551825920e+10</T_1250774650>
        <T_1250774540>9.1551825920e+10</T_1250774540>
        <T_1250774750>9.1551825920e+10</T_1250774750>
        <T_1250774640>9.1551825920e+10</T_1250774640>
        <T_1250774530>9.1551825920e+10</T_1250774530>
        <T_1250774740>9.1551825920e+10</T_1250774740>
        <T_1250774630>9.1551825920e+10</T_1250774630>
        <T_1250774730>9.1551825920e+10</T_1250774730>
        <T_1250774620>9.1551825920e+10</T_1250774620>
        <T_1250774830>9.1551825920e+10</T_1250774830>
        <T_1250774720>9.1551825920e+10</T_1250774720>
        <T_1250774610>9.1551825920e+10</T_1250774610>
      </free>
      <used>
        <T_1250774820>6.6340126720e+09</T_1250774820>
        <T_1250774710>6.6340126720e+09</T_1250774710>
        <T_1250774600>6.6340126720e+09</T_1250774600>
        <T_1250774590>6.6340126720e+09</T_1250774590>
        <T_1250774810>6.6340126720e+09</T_1250774810>
        <T_1250774700>6.6340126720e+09</T_1250774700>
        <T_1250774800>6.6340126720e+09</T_1250774800>
        <T_1250774690>6.6340126720e+09</T_1250774690>
        <T_1250774580>6.6340126720e+09</T_1250774580>
        <T_1250774790>6.6340126720e+09</T_1250774790>
        <T_1250774680>6.6340126720e+09</T_1250774680>
        <T_1250774570>6.6340126720e+09</T_1250774570>
        <T_1250774780>6.6340126720e+09</T_1250774780>
        <T_1250774670>6.6340126720e+09</T_1250774670>
        <T_1250774560>6.6340126720e+09</T_1250774560>
        <T_1250774770>6.6340126720e+09</T_1250774770>
        <T_1250774660>6.6340126720e+09</T_1250774660>
        <T_1250774550>6.6340126720e+09</T_1250774550>
        <T_1250774760>6.6340126720e+09</T_1250774760>
        <T_1250774650>6.6340126720e+09</T_1250774650>
        <T_1250774540>6.6340126720e+09</T_1250774540>
        <T_1250774750>6.6340126720e+09</T_1250774750>
        <T_1250774640>6.6340126720e+09</T_1250774640>
        <T_1250774530>6.6340126720e+09</T_1250774530>
        <T_1250774740>6.6340126720e+09</T_1250774740>
        <T_1250774630>6.6340126720e+09</T_1250774630>
        <T_1250774730>6.6340126720e+09</T_1250774730>
        <T_1250774620>6.6340126720e+09</T_1250774620>
        <T_1250774830>6.6340126720e+09</T_1250774830>
        <T_1250774720>6.6340126720e+09</T_1250774720>
        <T_1250774610>6.6340126720e+09</T_1250774610>
      </used>
    </df-windows-C>
    <df-suse-bin>
    </df-suse-bin>
    <df-windows-D>
      <free>
        <T_1250774820>3.2884621312e+10</T_1250774820>
        <T_1250774710>3.2884621312e+10</T_1250774710>
        <T_1250774600>3.2884621312e+10</T_1250774600>
        <T_1250774590>3.2884621312e+10</T_1250774590>
        <T_1250774810>3.2884621312e+10</T_1250774810>
        <T_1250774700>3.2884621312e+10</T_1250774700>
        <T_1250774800>3.2884621312e+10</T_1250774800>
        <T_1250774690>3.2884621312e+10</T_1250774690>
        <T_1250774580>3.2884621312e+10</T_1250774580>
        <T_1250774790>3.2884621312e+10</T_1250774790>
        <T_1250774680>3.2884621312e+10</T_1250774680>
        <T_1250774570>3.2884621312e+10</T_1250774570>
        <T_1250774780>3.2884621312e+10</T_1250774780>
        <T_1250774670>3.2884621312e+10</T_1250774670>
        <T_1250774560>3.2884621312e+10</T_1250774560>
        <T_1250774770>3.2884621312e+10</T_1250774770>
        <T_1250774660>3.2884621312e+10</T_1250774660>
        <T_1250774550>3.2884621312e+10</T_1250774550>
        <T_1250774760>3.2884621312e+10</T_1250774760>
        <T_1250774650>3.2884621312e+10</T_1250774650>
        <T_1250774540>3.2884621312e+10</T_1250774540>
        <T_1250774750>3.2884621312e+10</T_1250774750>
        <T_1250774640>3.2884621312e+10</T_1250774640>
        <T_1250774530>3.2884621312e+10</T_1250774530>
        <T_1250774740>3.2884621312e+10</T_1250774740>
        <T_1250774630>3.2884621312e+10</T_1250774630>
        <T_1250774730>3.2884621312e+10</T_1250774730>
        <T_1250774620>3.2884621312e+10</T_1250774620>
        <T_1250774830>3.2884621312e+10</T_1250774830>
        <T_1250774720>3.2884621312e+10</T_1250774720>
        <T_1250774610>3.2884621312e+10</T_1250774610>
      </free>
      <used>
        <T_1250774820>1.3107200000e+05</T_1250774820>
        <T_1250774710>1.3107200000e+05</T_1250774710>
        <T_1250774600>1.3107200000e+05</T_1250774600>
        <T_1250774590>1.3107200000e+05</T_1250774590>
        <T_1250774810>1.3107200000e+05</T_1250774810>
        <T_1250774700>1.3107200000e+05</T_1250774700>
        <T_1250774800>1.3107200000e+05</T_1250774800>
        <T_1250774690>1.3107200000e+05</T_1250774690>
        <T_1250774580>1.3107200000e+05</T_1250774580>
        <T_1250774790>1.3107200000e+05</T_1250774790>
        <T_1250774680>1.3107200000e+05</T_1250774680>
        <T_1250774570>1.3107200000e+05</T_1250774570>
        <T_1250774780>1.3107200000e+05</T_1250774780>
        <T_1250774670>1.3107200000e+05</T_1250774670>
        <T_1250774560>1.3107200000e+05</T_1250774560>
        <T_1250774770>1.3107200000e+05</T_1250774770>
        <T_1250774660>1.3107200000e+05</T_1250774660>
        <T_1250774550>1.3107200000e+05</T_1250774550>
        <T_1250774760>1.3107200000e+05</T_1250774760>
        <T_1250774650>1.3107200000e+05</T_1250774650>
        <T_1250774540>1.3107200000e+05</T_1250774540>
        <T_1250774750>1.3107200000e+05</T_1250774750>
        <T_1250774640>1.3107200000e+05</T_1250774640>
        <T_1250774530>1.3107200000e+05</T_1250774530>
        <T_1250774740>1.3107200000e+05</T_1250774740>
        <T_1250774630>1.3107200000e+05</T_1250774630>
        <T_1250774730>1.3107200000e+05</T_1250774730>
        <T_1250774620>1.3107200000e+05</T_1250774620>
        <T_1250774830>1.3107200000e+05</T_1250774830>
        <T_1250774720>1.3107200000e+05</T_1250774720>
        <T_1250774610>1.3107200000e+05</T_1250774610>
      </used>
    </df-windows-D>
    <df-suse-ma>
      <free>
        <T_1250774820>1.0766101709e+11</T_1250774820>
        <T_1250774710>1.0766132838e+11</T_1250774710>
        <T_1250774600>1.0764546867e+11</T_1250774600>
        <T_1250774590>1.0764533760e+11</T_1250774590>
        <T_1250774810>1.0766189363e+11</T_1250774810>
        <T_1250774700>1.0766363034e+11</T_1250774700>
        <T_1250774800>1.0766028800e+11</T_1250774800>
        <T_1250774690>1.0766562099e+11</T_1250774690>
        <T_1250774580>1.0764742656e+11</T_1250774580>
        <T_1250774790>1.0766360576e+11</T_1250774790>
        <T_1250774680>1.0766526054e+11</T_1250774680>
        <T_1250774570>1.0764861440e+11</T_1250774570>
        <T_1250774780>1.0766278656e+11</T_1250774780>
        <T_1250774670>1.0766553088e+11</T_1250774670>
        <T_1250774560>1.0764886016e+11</T_1250774560>
        <T_1250774770>1.0766354842e+11</T_1250774770>
        <T_1250774660>1.0766514586e+11</T_1250774660>
        <T_1250774550>1.0765020365e+11</T_1250774550>
        <T_1250774760>1.0766349926e+11</T_1250774760>
        <T_1250774650>1.0766512947e+11</T_1250774650>
        <T_1250774540>1.0765167821e+11</T_1250774540>
        <T_1250774750>1.0766503936e+11</T_1250774750>
        <T_1250774640>1.0766453965e+11</T_1250774640>
        <T_1250774530>1.0765232538e+11</T_1250774530>
        <T_1250774740>1.0767238758e+11</T_1250774740>
        <T_1250774630>1.0766330266e+11</T_1250774630>
        <T_1250774730>1.0766376141e+11</T_1250774730>
        <T_1250774620>1.0765415219e+11</T_1250774620>
        <T_1250774830>1.0766434304e+11</T_1250774830>
        <T_1250774720>1.0766377779e+11</T_1250774720>
        <T_1250774610>1.0765327565e+11</T_1250774610>
      </free>
      <used>
        <T_1250774820>7.8053822464e+11</T_1250774820>
        <T_1250774710>7.8053791334e+11</T_1250774710>
        <T_1250774600>7.8055377306e+11</T_1250774600>
        <T_1250774590>7.8055390413e+11</T_1250774590>
        <T_1250774810>7.8053734810e+11</T_1250774810>
        <T_1250774700>7.8053561139e+11</T_1250774700>
        <T_1250774800>7.8053895373e+11</T_1250774800>
        <T_1250774690>7.8053362074e+11</T_1250774690>
        <T_1250774580>7.8055181517e+11</T_1250774580>
        <T_1250774790>7.8053563597e+11</T_1250774790>
        <T_1250774680>7.8053398118e+11</T_1250774680>
        <T_1250774570>7.8055062733e+11</T_1250774570>
        <T_1250774780>7.8053645517e+11</T_1250774780>
        <T_1250774670>7.8053371085e+11</T_1250774670>
        <T_1250774560>7.8055038157e+11</T_1250774560>
        <T_1250774770>7.8053569331e+11</T_1250774770>
        <T_1250774660>7.8053409587e+11</T_1250774660>
        <T_1250774550>7.8054903808e+11</T_1250774550>
        <T_1250774760>7.8053574246e+11</T_1250774760>
        <T_1250774650>7.8053411226e+11</T_1250774650>
        <T_1250774540>7.8054756352e+11</T_1250774540>
        <T_1250774750>7.8053420237e+11</T_1250774750>
        <T_1250774640>7.8053470208e+11</T_1250774640>
        <T_1250774530>7.8054691635e+11</T_1250774530>
        <T_1250774740>7.8052685414e+11</T_1250774740>
        <T_1250774630>7.8053593907e+11</T_1250774630>
        <T_1250774730>7.8053548032e+11</T_1250774730>
        <T_1250774620>7.8054508954e+11</T_1250774620>
        <T_1250774830>7.8053489869e+11</T_1250774830>
        <T_1250774720>7.8053546394e+11</T_1250774720>
        <T_1250774610>7.8054596608e+11</T_1250774610>
      </used>
    </df-suse-ma>
    <df-root>
      <free>
        <T_1250774820>1.5400800256e+10</T_1250774820>
        <T_1250774710>1.5400992768e+10</T_1250774710>
        <T_1250774600>1.5401529344e+10</T_1250774600>
        <T_1250774590>1.5401472000e+10</T_1250774590>
        <T_1250774810>1.5400800256e+10</T_1250774810>
        <T_1250774700>1.5400992768e+10</T_1250774700>
        <T_1250774800>1.5400800256e+10</T_1250774800>
        <T_1250774690>1.5400939520e+10</T_1250774690>
        <T_1250774580>1.5401541632e+10</T_1250774580>
        <T_1250774790>1.5400800256e+10</T_1250774790>
        <T_1250774680>1.5400960000e+10</T_1250774680>
        <T_1250774570>1.5401541632e+10</T_1250774570>
        <T_1250774780>1.5400804352e+10</T_1250774780>
        <T_1250774670>1.5401312256e+10</T_1250774670>
        <T_1250774560>1.5401541632e+10</T_1250774560>
        <T_1250774770>1.5400804352e+10</T_1250774770>
        <T_1250774660>1.5401447424e+10</T_1250774660>
        <T_1250774550>1.5401541632e+10</T_1250774550>
        <T_1250774760>1.5400771584e+10</T_1250774760>
        <T_1250774650>1.5401451520e+10</T_1250774650>
        <T_1250774540>1.5401541632e+10</T_1250774540>
        <T_1250774750>1.5400951808e+10</T_1250774750>
        <T_1250774640>1.5401529344e+10</T_1250774640>
        <T_1250774530>1.5401541632e+10</T_1250774530>
        <T_1250774740>1.5400951808e+10</T_1250774740>
        <T_1250774630>1.5401529344e+10</T_1250774630>
        <T_1250774730>1.5400951808e+10</T_1250774730>
        <T_1250774620>1.5401529344e+10</T_1250774620>
        <T_1250774830>1.5400800256e+10</T_1250774830>
        <T_1250774720>1.5400951808e+10</T_1250774720>
        <T_1250774610>1.5401529344e+10</T_1250774610>
      </free>
      <used>
        <T_1250774820>4.9313624064e+10</T_1250774820>
        <T_1250774710>4.9313431552e+10</T_1250774710>
        <T_1250774600>4.9312894976e+10</T_1250774600>
        <T_1250774590>4.9312952320e+10</T_1250774590>
        <T_1250774810>4.9313624064e+10</T_1250774810>
        <T_1250774700>4.9313431552e+10</T_1250774700>
        <T_1250774800>4.9313624064e+10</T_1250774800>
        <T_1250774690>4.9313484800e+10</T_1250774690>
        <T_1250774580>4.9312882688e+10</T_1250774580>
        <T_1250774790>4.9313624064e+10</T_1250774790>
        <T_1250774680>4.9313464320e+10</T_1250774680>
        <T_1250774570>4.9312882688e+10</T_1250774570>
        <T_1250774780>4.9313619968e+10</T_1250774780>
        <T_1250774670>4.9313112064e+10</T_1250774670>
        <T_1250774560>4.9312882688e+10</T_1250774560>
        <T_1250774770>4.9313619968e+10</T_1250774770>
        <T_1250774660>4.9312976896e+10</T_1250774660>
        <T_1250774550>4.9312882688e+10</T_1250774550>
        <T_1250774760>4.9313652736e+10</T_1250774760>
        <T_1250774650>4.9312972800e+10</T_1250774650>
        <T_1250774540>4.9312882688e+10</T_1250774540>
        <T_1250774750>4.9313472512e+10</T_1250774750>
        <T_1250774640>4.9312894976e+10</T_1250774640>
        <T_1250774530>4.9312882688e+10</T_1250774530>
        <T_1250774740>4.9313472512e+10</T_1250774740>
        <T_1250774630>4.9312894976e+10</T_1250774630>
        <T_1250774730>4.9313472512e+10</T_1250774730>
        <T_1250774620>4.9312894976e+10</T_1250774620>
        <T_1250774830>4.9313624064e+10</T_1250774830>
        <T_1250774720>4.9313472512e+10</T_1250774720>
        <T_1250774610>4.9312894976e+10</T_1250774610>
      </used>
    </df-root>
    <df-mounts-work>
      <free>
        <T_1250774820>1.0106776781e+11</T_1250774820>
        <T_1250774710>1.0106776781e+11</T_1250774710>
        <T_1250774810>1.0106776781e+11</T_1250774810>
        <T_1250774700>1.0106776781e+11</T_1250774700>
        <T_1250774800>1.0106776781e+11</T_1250774800>
        <T_1250774690>1.0106776781e+11</T_1250774690>
        <T_1250774790>1.0106776781e+11</T_1250774790>
        <T_1250774780>1.0106776781e+11</T_1250774780>
        <T_1250774770>1.0106776781e+11</T_1250774770>
        <T_1250774760>1.0106776781e+11</T_1250774760>
        <T_1250774750>1.0106776781e+11</T_1250774750>
        <T_1250774740>1.0106776781e+11</T_1250774740>
        <T_1250774730>1.0106776781e+11</T_1250774730>
        <T_1250774830>1.0106776781e+11</T_1250774830>
        <T_1250774720>1.0106776781e+11</T_1250774720>
      </free>
      <used>
        <T_1250774820>2.7365669274e+11</T_1250774820>
        <T_1250774710>2.7365669274e+11</T_1250774710>
        <T_1250774810>2.7365669274e+11</T_1250774810>
        <T_1250774700>2.7365669274e+11</T_1250774700>
        <T_1250774800>2.7365669274e+11</T_1250774800>
        <T_1250774690>2.7365669274e+11</T_1250774690>
        <T_1250774790>2.7365669274e+11</T_1250774790>
        <T_1250774780>2.7365669274e+11</T_1250774780>
        <T_1250774770>2.7365669274e+11</T_1250774770>
        <T_1250774760>2.7365669274e+11</T_1250774760>
        <T_1250774750>2.7365669274e+11</T_1250774750>
        <T_1250774740>2.7365669274e+11</T_1250774740>
        <T_1250774730>2.7365669274e+11</T_1250774730>
        <T_1250774830>2.7365669274e+11</T_1250774830>
        <T_1250774720>2.7365669274e+11</T_1250774720>
      </used>
    </df-mounts-work>
    <df-suse-present>
    </df-suse-present>
    <df-dev>
      <free>
        <T_1250774820>5.2947763200e+08</T_1250774820>
        <T_1250774710>5.2947763200e+08</T_1250774710>
        <T_1250774600>5.2947763200e+08</T_1250774600>
        <T_1250774590>5.2947763200e+08</T_1250774590>
        <T_1250774810>5.2947763200e+08</T_1250774810>
        <T_1250774700>5.2947763200e+08</T_1250774700>
        <T_1250774800>5.2947763200e+08</T_1250774800>
        <T_1250774690>5.2947763200e+08</T_1250774690>
        <T_1250774580>5.2947763200e+08</T_1250774580>
        <T_1250774790>5.2947763200e+08</T_1250774790>
        <T_1250774680>5.2947763200e+08</T_1250774680>
        <T_1250774570>5.2947763200e+08</T_1250774570>
        <T_1250774780>5.2947763200e+08</T_1250774780>
        <T_1250774670>5.2947763200e+08</T_1250774670>
        <T_1250774560>5.2947763200e+08</T_1250774560>
        <T_1250774770>5.2947763200e+08</T_1250774770>
        <T_1250774660>5.2947763200e+08</T_1250774660>
        <T_1250774550>5.2947763200e+08</T_1250774550>
        <T_1250774760>5.2947763200e+08</T_1250774760>
        <T_1250774650>5.2947763200e+08</T_1250774650>
        <T_1250774540>5.2947763200e+08</T_1250774540>
        <T_1250774750>5.2947763200e+08</T_1250774750>
        <T_1250774640>5.2947763200e+08</T_1250774640>
        <T_1250774530>5.2947763200e+08</T_1250774530>
        <T_1250774740>5.2947763200e+08</T_1250774740>
        <T_1250774630>5.2947763200e+08</T_1250774630>
        <T_1250774730>5.2947763200e+08</T_1250774730>
        <T_1250774620>5.2947763200e+08</T_1250774620>
        <T_1250774830>5.2947763200e+08</T_1250774830>
        <T_1250774720>5.2947763200e+08</T_1250774720>
        <T_1250774610>5.2947763200e+08</T_1250774610>
      </free>
      <used>
        <T_1250774820>3.9731200000e+05</T_1250774820>
        <T_1250774710>3.9731200000e+05</T_1250774710>
        <T_1250774600>3.9731200000e+05</T_1250774600>
        <T_1250774590>3.9731200000e+05</T_1250774590>
        <T_1250774810>3.9731200000e+05</T_1250774810>
        <T_1250774700>3.9731200000e+05</T_1250774700>
        <T_1250774800>3.9731200000e+05</T_1250774800>
        <T_1250774690>3.9731200000e+05</T_1250774690>
        <T_1250774580>3.9731200000e+05</T_1250774580>
        <T_1250774790>3.9731200000e+05</T_1250774790>
        <T_1250774680>3.9731200000e+05</T_1250774680>
        <T_1250774570>3.9731200000e+05</T_1250774570>
        <T_1250774780>3.9731200000e+05</T_1250774780>
        <T_1250774670>3.9731200000e+05</T_1250774670>
        <T_1250774560>3.9731200000e+05</T_1250774560>
        <T_1250774770>3.9731200000e+05</T_1250774770>
        <T_1250774660>3.9731200000e+05</T_1250774660>
        <T_1250774550>3.9731200000e+05</T_1250774550>
        <T_1250774760>3.9731200000e+05</T_1250774760>
        <T_1250774650>3.9731200000e+05</T_1250774650>
        <T_1250774540>3.9731200000e+05</T_1250774540>
        <T_1250774750>3.9731200000e+05</T_1250774750>
        <T_1250774640>3.9731200000e+05</T_1250774640>
        <T_1250774530>3.9731200000e+05</T_1250774530>
        <T_1250774740>3.9731200000e+05</T_1250774740>
        <T_1250774630>3.9731200000e+05</T_1250774630>
        <T_1250774730>3.9731200000e+05</T_1250774730>
        <T_1250774620>3.9731200000e+05</T_1250774620>
        <T_1250774830>3.9731200000e+05</T_1250774830>
        <T_1250774720>3.9731200000e+05</T_1250774720>
        <T_1250774610>3.9731200000e+05</T_1250774610>
      </used>
    </df-dev>
  </df>
  <memory>
    <memory-used>
      <value>
        <T_1250774820>7.3029222400e+08</T_1250774820>
        <T_1250774710>7.3044787200e+08</T_1250774710>
        <T_1250774600>7.4470195200e+08</T_1250774600>
        <T_1250774590>7.3993420800e+08</T_1250774590>
        <T_1250774810>7.3041920000e+08</T_1250774810>
        <T_1250774700>7.3048064000e+08</T_1250774700>
        <T_1250774800>7.3070592000e+08</T_1250774800>
        <T_1250774690>7.5667865600e+08</T_1250774690>
        <T_1250774580>7.2812134400e+08</T_1250774580>
        <T_1250774790>7.3035366400e+08</T_1250774790>
        <T_1250774680>7.4611916800e+08</T_1250774680>
        <T_1250774570>7.2286617600e+08</T_1250774570>
        <T_1250774780>7.3012019200e+08</T_1250774780>
        <T_1250774670>7.3796812800e+08</T_1250774670>
        <T_1250774560>6.9454233600e+08</T_1250774560>
        <T_1250774770>7.3049702400e+08</T_1250774770>
        <T_1250774660>7.5069849600e+08</T_1250774660>
        <T_1250774550>6.9455872000e+08</T_1250774550>
        <T_1250774760>7.5517542400e+08</T_1250774760>
        <T_1250774650>7.4998579200e+08</T_1250774650>
        <T_1250774540>6.9441536000e+08</T_1250774540>
        <T_1250774750>7.3028812800e+08</T_1250774750>
        <T_1250774640>7.4989977600e+08</T_1250774640>
        <T_1250774530>6.9462425600e+08</T_1250774530>
        <T_1250774740>7.3011609600e+08</T_1250774740>
        <T_1250774630>7.4983424000e+08</T_1250774630>
        <T_1250774730>7.3024307200e+08</T_1250774730>
        <T_1250774620>7.4729472000e+08</T_1250774620>
        <T_1250774830>7.3015705600e+08</T_1250774830>
        <T_1250774720>7.3037004800e+08</T_1250774720>
        <T_1250774610>7.4480844800e+08</T_1250774610>
      </value>
    </memory-used>
    <memory-buffered>
      <value>
        <T_1250774820>4.4007424000e+07</T_1250774820>
        <T_1250774710>4.3909120000e+07</T_1250774710>
        <T_1250774600>4.3085824000e+07</T_1250774600>
        <T_1250774590>4.3085824000e+07</T_1250774590>
        <T_1250774810>4.4007424000e+07</T_1250774810>
        <T_1250774700>4.3909120000e+07</T_1250774700>
        <T_1250774800>4.4007424000e+07</T_1250774800>
        <T_1250774690>4.3905024000e+07</T_1250774690>
        <T_1250774580>4.3085824000e+07</T_1250774580>
        <T_1250774790>4.4007424000e+07</T_1250774790>
        <T_1250774680>4.3876352000e+07</T_1250774680>
        <T_1250774570>4.3085824000e+07</T_1250774570>
        <T_1250774780>4.3937792000e+07</T_1250774780>
        <T_1250774670>4.3622400000e+07</T_1250774670>
        <T_1250774560>4.3085824000e+07</T_1250774560>
        <T_1250774770>4.3909120000e+07</T_1250774770>
        <T_1250774660>4.3225088000e+07</T_1250774660>
        <T_1250774550>4.3085824000e+07</T_1250774550>
        <T_1250774760>4.3909120000e+07</T_1250774760>
        <T_1250774650>4.3212800000e+07</T_1250774650>
        <T_1250774540>4.3085824000e+07</T_1250774540>
        <T_1250774750>4.3909120000e+07</T_1250774750>
        <T_1250774640>4.3212800000e+07</T_1250774640>
        <T_1250774530>4.3085824000e+07</T_1250774530>
        <T_1250774740>4.3909120000e+07</T_1250774740>
        <T_1250774630>4.3212800000e+07</T_1250774630>
        <T_1250774730>4.3909120000e+07</T_1250774730>
        <T_1250774620>4.3184128000e+07</T_1250774620>
        <T_1250774830>4.4007424000e+07</T_1250774830>
        <T_1250774720>4.3909120000e+07</T_1250774720>
        <T_1250774610>4.3085824000e+07</T_1250774610>
      </value>
    </memory-buffered>
    <memory-cached>
      <value>
        <T_1250774820>2.5054822400e+08</T_1250774820>
        <T_1250774710>2.4512512000e+08</T_1250774710>
        <T_1250774600>2.2180659200e+08</T_1250774600>
        <T_1250774590>2.2133145600e+08</T_1250774590>
        <T_1250774810>2.5054822400e+08</T_1250774810>
        <T_1250774700>2.4511692800e+08</T_1250774700>
        <T_1250774800>2.5054822400e+08</T_1250774800>
        <T_1250774690>2.4513331200e+08</T_1250774690>
        <T_1250774580>2.2133555200e+08</T_1250774580>
        <T_1250774790>2.4515379200e+08</T_1250774790>
        <T_1250774680>2.5067520000e+08</T_1250774680>
        <T_1250774570>2.2133555200e+08</T_1250774570>
        <T_1250774780>2.4268800000e+08</T_1250774780>
        <T_1250774670>2.3780147200e+08</T_1250774670>
        <T_1250774560>2.2133145600e+08</T_1250774560>
        <T_1250774770>2.4247910400e+08</T_1250774770>
        <T_1250774660>2.2197452800e+08</T_1250774660>
        <T_1250774550>2.2132736000e+08</T_1250774550>
        <T_1250774760>2.4240128000e+08</T_1250774760>
        <T_1250774650>2.2188851200e+08</T_1250774650>
        <T_1250774540>2.2124544000e+08</T_1250774540>
        <T_1250774750>2.4521113600e+08</T_1250774750>
        <T_1250774640>2.2188032000e+08</T_1250774640>
        <T_1250774530>2.2124544000e+08</T_1250774530>
        <T_1250774740>2.4521113600e+08</T_1250774740>
        <T_1250774630>2.2188032000e+08</T_1250774630>
        <T_1250774730>2.4521113600e+08</T_1250774730>
        <T_1250774620>2.2177792000e+08</T_1250774620>
        <T_1250774830>2.5054822400e+08</T_1250774830>
        <T_1250774720>2.4521113600e+08</T_1250774720>
        <T_1250774610>2.2180659200e+08</T_1250774610>
      </value>
    </memory-cached>
    <memory-free>
      <value>
        <T_1250774820>3.4902016000e+07</T_1250774820>
        <T_1250774710>4.0267776000e+07</T_1250774710>
        <T_1250774600>5.0155520000e+07</T_1250774600>
        <T_1250774590>5.5398400000e+07</T_1250774590>
        <T_1250774810>3.4775040000e+07</T_1250774810>
        <T_1250774700>4.0243200000e+07</T_1250774700>
        <T_1250774800>3.4488320000e+07</T_1250774800>
        <T_1250774690>1.4032896000e+07</T_1250774690>
        <T_1250774580>6.7207168000e+07</T_1250774580>
        <T_1250774790>4.0235008000e+07</T_1250774790>
        <T_1250774680>1.9079168000e+07</T_1250774680>
        <T_1250774570>7.2462336000e+07</T_1250774570>
        <T_1250774780>4.3003904000e+07</T_1250774780>
        <T_1250774670>4.0357888000e+07</T_1250774670>
        <T_1250774560>1.0079027200e+08</T_1250774560>
        <T_1250774770>4.2864640000e+07</T_1250774770>
        <T_1250774660>4.3851776000e+07</T_1250774660>
        <T_1250774550>1.0077798400e+08</T_1250774550>
        <T_1250774760>1.8264064000e+07</T_1250774760>
        <T_1250774650>4.4662784000e+07</T_1250774650>
        <T_1250774540>1.0100326400e+08</T_1250774540>
        <T_1250774750>4.0341504000e+07</T_1250774750>
        <T_1250774640>4.4756992000e+07</T_1250774640>
        <T_1250774530>1.0079436800e+08</T_1250774530>
        <T_1250774740>4.0513536000e+07</T_1250774740>
        <T_1250774630>4.4822528000e+07</T_1250774630>
        <limit>
          <maximum type="boolean">false</maximum>
          <value type="float">104857600.0</value>
        </limit>
        <T_1250774730>4.0386560000e+07</T_1250774730>
        <T_1250774620>4.7493120000e+07</T_1250774620>
        <T_1250774830>3.5037184000e+07</T_1250774830>
        <T_1250774720>4.0259584000e+07</T_1250774720>
        <T_1250774610>5.0049024000e+07</T_1250774610>
      </value>
    </memory-free>
  </memory>
  <cpu-0>
    <cpu-system>
      <value>
        <T_1250774820>3.0000000000e-01</T_1250774820>
        <T_1250774710>0.0000000000e+00</T_1250774710>
        <T_1250774600>9.0000000000e-01</T_1250774600>
        <T_1250774590>1.4000000000e+00</T_1250774590>
        <T_1250774810>2.0000000000e-01</T_1250774810>
        <T_1250774700>3.0000000000e-01</T_1250774700>
        <T_1250774800>2.3000000000e+00</T_1250774800>
        <T_1250774690>4.9000000000e+00</T_1250774690>
        <T_1250774580>4.8000000000e+00</T_1250774580>
        <T_1250774790>3.0000000000e-01</T_1250774790>
        <T_1250774680>7.5000000000e+00</T_1250774680>
        <T_1250774570>4.4000000000e+00</T_1250774570>
        <T_1250774780>3.0000000000e-01</T_1250774780>
        <T_1250774670>5.5000000000e+00</T_1250774670>
        <T_1250774560>6.0000000000e-01</T_1250774560>
        <T_1250774770>3.0000000000e-01</T_1250774770>
        <T_1250774660>1.0000000000e+00</T_1250774660>
        <T_1250774550>2.0000000000e-01</T_1250774550>
        <T_1250774760>4.0000000000e+00</T_1250774760>
        <T_1250774650>1.6000000000e+00</T_1250774650>
        <T_1250774540>0.0000000000e+00</T_1250774540>
        <T_1250774750>2.0000000000e-01</T_1250774750>
        <T_1250774640>5.0000000000e-01</T_1250774640>
        <T_1250774530>0.0000000000e+00</T_1250774530>
        <T_1250774740>2.0000000000e-01</T_1250774740>
        <T_1250774630>1.0000000000e-01</T_1250774630>
        <T_1250774730>1.0000000000e-01</T_1250774730>
        <T_1250774620>2.0000000000e-01</T_1250774620>
        <T_1250774830>2.0000000000e-01</T_1250774830>
        <T_1250774720>7.0000000000e-01</T_1250774720>
        <T_1250774610>3.0000000000e-01</T_1250774610>
      </value>
    </cpu-system>
    <cpu-steal>
      <value>
        <T_1250774820>0.0000000000e+00</T_1250774820>
        <T_1250774710>0.0000000000e+00</T_1250774710>
        <T_1250774600>0.0000000000e+00</T_1250774600>
        <T_1250774590>0.0000000000e+00</T_1250774590>
        <T_1250774810>0.0000000000e+00</T_1250774810>
        <T_1250774700>0.0000000000e+00</T_1250774700>
        <T_1250774800>0.0000000000e+00</T_1250774800>
        <T_1250774690>0.0000000000e+00</T_1250774690>
        <T_1250774580>0.0000000000e+00</T_1250774580>
        <T_1250774790>0.0000000000e+00</T_1250774790>
        <T_1250774680>0.0000000000e+00</T_1250774680>
        <T_1250774570>0.0000000000e+00</T_1250774570>
        <T_1250774780>0.0000000000e+00</T_1250774780>
        <T_1250774670>0.0000000000e+00</T_1250774670>
        <T_1250774560>0.0000000000e+00</T_1250774560>
        <T_1250774770>0.0000000000e+00</T_1250774770>
        <T_1250774660>0.0000000000e+00</T_1250774660>
        <T_1250774550>0.0000000000e+00</T_1250774550>
        <T_1250774760>0.0000000000e+00</T_1250774760>
        <T_1250774650>0.0000000000e+00</T_1250774650>
        <T_1250774540>0.0000000000e+00</T_1250774540>
        <T_1250774750>0.0000000000e+00</T_1250774750>
        <T_1250774640>0.0000000000e+00</T_1250774640>
        <T_1250774530>0.0000000000e+00</T_1250774530>
        <T_1250774740>0.0000000000e+00</T_1250774740>
        <T_1250774630>0.0000000000e+00</T_1250774630>
        <T_1250774730>0.0000000000e+00</T_1250774730>
        <T_1250774620>0.0000000000e+00</T_1250774620>
        <T_1250774830>0.0000000000e+00</T_1250774830>
        <T_1250774720>0.0000000000e+00</T_1250774720>
        <T_1250774610>0.0000000000e+00</T_1250774610>
      </value>
    </cpu-steal>
    <cpu-nice>
      <value>
        <T_1250774820>0.0000000000e+00</T_1250774820>
        <T_1250774710>0.0000000000e+00</T_1250774710>
        <T_1250774600>0.0000000000e+00</T_1250774600>
        <T_1250774590>0.0000000000e+00</T_1250774590>
        <T_1250774810>0.0000000000e+00</T_1250774810>
        <T_1250774700>0.0000000000e+00</T_1250774700>
        <T_1250774800>9.0000000000e-01</T_1250774800>
        <T_1250774690>0.0000000000e+00</T_1250774690>
        <T_1250774580>0.0000000000e+00</T_1250774580>
        <T_1250774790>0.0000000000e+00</T_1250774790>
        <T_1250774680>0.0000000000e+00</T_1250774680>
        <T_1250774570>0.0000000000e+00</T_1250774570>
        <T_1250774780>0.0000000000e+00</T_1250774780>
        <T_1250774670>2.0000000000e-01</T_1250774670>
        <T_1250774560>0.0000000000e+00</T_1250774560>
        <T_1250774770>0.0000000000e+00</T_1250774770>
        <T_1250774660>0.0000000000e+00</T_1250774660>
        <T_1250774550>0.0000000000e+00</T_1250774550>
        <T_1250774760>0.0000000000e+00</T_1250774760>
        <T_1250774650>2.0000000000e-01</T_1250774650>
        <T_1250774540>0.0000000000e+00</T_1250774540>
        <T_1250774750>0.0000000000e+00</T_1250774750>
        <T_1250774640>0.0000000000e+00</T_1250774640>
        <T_1250774530>0.0000000000e+00</T_1250774530>
        <T_1250774740>0.0000000000e+00</T_1250774740>
        <T_1250774630>0.0000000000e+00</T_1250774630>
        <T_1250774730>0.0000000000e+00</T_1250774730>
        <T_1250774620>0.0000000000e+00</T_1250774620>
        <T_1250774830>0.0000000000e+00</T_1250774830>
        <T_1250774720>7.0000000000e-01</T_1250774720>
        <T_1250774610>0.0000000000e+00</T_1250774610>
      </value>
    </cpu-nice>
    <cpu-idle>
      <value>
        <T_1250774820>9.9700000000e+01</T_1250774820>
        <T_1250774710>9.9800000000e+01</T_1250774710>
        <T_1250774600>6.7700000000e+01</T_1250774600>
        <T_1250774590>6.2700000000e+01</T_1250774590>
        <T_1250774810>9.9800000000e+01</T_1250774810>
        <T_1250774700>9.9000000000e+01</T_1250774700>
        <T_1250774800>9.1500000000e+01</T_1250774800>
        <T_1250774690>5.2500000000e+01</T_1250774690>
        <T_1250774580>8.3600000000e+01</T_1250774580>
        <T_1250774790>9.6400000000e+01</T_1250774790>
        <T_1250774680>3.3800000000e+01</T_1250774680>
        <T_1250774570>6.4200000000e+01</T_1250774570>
        <T_1250774780>9.8100000000e+01</T_1250774780>
        <T_1250774670>5.1600000000e+01</T_1250774670>
        <T_1250774560>9.4400000000e+01</T_1250774560>
        <T_1250774770>7.9600000000e+01</T_1250774770>
        <T_1250774660>9.1500000000e+01</T_1250774660>
        <T_1250774550>9.8800000000e+01</T_1250774550>
        <T_1250774760>4.7400000000e+01</T_1250774760>
        <T_1250774650>6.7500000000e+01</T_1250774650>
        <T_1250774540>9.9600000000e+01</T_1250774540>
        <T_1250774750>7.9500000000e+01</T_1250774750>
        <T_1250774640>9.8400000000e+01</T_1250774640>
        <T_1250774530>9.9600000000e+01</T_1250774530>
        <T_1250774740>9.9300000000e+01</T_1250774740>
        <T_1250774630>9.6900000000e+01</T_1250774630>
        <T_1250774730>9.9800000000e+01</T_1250774730>
        <T_1250774620>9.7000000000e+01</T_1250774620>
        <T_1250774830>9.9600000000e+01</T_1250774830>
        <T_1250774720>9.6100000000e+01</T_1250774720>
        <T_1250774610>9.5600000000e+01</T_1250774610>
      </value>
    </cpu-idle>
    <cpu-softirq>
      <value>
        <T_1250774820>0.0000000000e+00</T_1250774820>
        <T_1250774710>1.0000000000e-01</T_1250774710>
        <T_1250774600>2.0000000000e-01</T_1250774600>
        <T_1250774590>0.0000000000e+00</T_1250774590>
        <T_1250774810>0.0000000000e+00</T_1250774810>
        <T_1250774700>1.0000000000e-01</T_1250774700>
        <T_1250774800>1.9000000000e+00</T_1250774800>
        <T_1250774690>0.0000000000e+00</T_1250774690>
        <T_1250774580>1.0000000000e-01</T_1250774580>
        <T_1250774790>1.0000000000e-01</T_1250774790>
        <T_1250774680>3.0000000000e-01</T_1250774680>
        <T_1250774570>1.0000000000e-01</T_1250774570>
        <T_1250774780>0.0000000000e+00</T_1250774780>
        <T_1250774670>1.0000000000e-01</T_1250774670>
        <T_1250774560>1.0000000000e-01</T_1250774560>
        <T_1250774770>2.0000000000e-01</T_1250774770>
        <T_1250774660>0.0000000000e+00</T_1250774660>
        <T_1250774550>0.0000000000e+00</T_1250774550>
        <T_1250774760>2.0000000000e-01</T_1250774760>
        <T_1250774650>1.0000000000e-01</T_1250774650>
        <T_1250774540>0.0000000000e+00</T_1250774540>
        <T_1250774750>1.0000000000e-01</T_1250774750>
        <T_1250774640>0.0000000000e+00</T_1250774640>
        <T_1250774530>1.0000000000e-01</T_1250774530>
        <T_1250774740>0.0000000000e+00</T_1250774740>
        <T_1250774630>0.0000000000e+00</T_1250774630>
        <T_1250774730>0.0000000000e+00</T_1250774730>
        <T_1250774620>1.0000000000e-01</T_1250774620>
        <T_1250774830>0.0000000000e+00</T_1250774830>
        <T_1250774720>0.0000000000e+00</T_1250774720>
        <T_1250774610>0.0000000000e+00</T_1250774610>
      </value>
    </cpu-softirq>
    <cpu-wait>
      <value>
        <T_1250774820>0.0000000000e+00</T_1250774820>
        <T_1250774710>0.0000000000e+00</T_1250774710>
        <T_1250774600>1.0000000000e-01</T_1250774600>
        <T_1250774590>1.0000000000e-01</T_1250774590>
        <T_1250774810>0.0000000000e+00</T_1250774810>
        <T_1250774700>0.0000000000e+00</T_1250774700>
        <T_1250774800>1.5000000000e+00</T_1250774800>
        <T_1250774690>5.9000000000e+00</T_1250774690>
        <T_1250774580>0.0000000000e+00</T_1250774580>
        <T_1250774790>3.0000000000e-01</T_1250774790>
        <T_1250774680>9.0000000000e+00</T_1250774680>
        <T_1250774570>0.0000000000e+00</T_1250774570>
        <T_1250774780>3.0000000000e-01</T_1250774780>
        <T_1250774670>1.7600000000e+01</T_1250774670>
        <T_1250774560>0.0000000000e+00</T_1250774560>
        <T_1250774770>1.0000000000e-01</T_1250774770>
        <T_1250774660>3.0000000000e-01</T_1250774660>
        <T_1250774550>0.0000000000e+00</T_1250774550>
        <T_1250774760>9.0000000000e-01</T_1250774760>
        <T_1250774650>0.0000000000e+00</T_1250774650>
        <T_1250774540>0.0000000000e+00</T_1250774540>
        <T_1250774750>0.0000000000e+00</T_1250774750>
        <T_1250774640>0.0000000000e+00</T_1250774640>
        <T_1250774530>0.0000000000e+00</T_1250774530>
        <T_1250774740>0.0000000000e+00</T_1250774740>
        <T_1250774630>4.0000000000e-01</T_1250774630>
        <T_1250774730>0.0000000000e+00</T_1250774730>
        <T_1250774620>7.0000000000e-01</T_1250774620>
        <T_1250774830>0.0000000000e+00</T_1250774830>
        <T_1250774720>2.2000000000e+00</T_1250774720>
        <T_1250774610>0.0000000000e+00</T_1250774610>
      </value>
    </cpu-wait>
    <cpu-user>
      <value>
        <T_1250774820>2.0000000000e-01</T_1250774820>
        <T_1250774710>3.0000000000e-01</T_1250774710>
        <T_1250774600>3.1400000000e+01</T_1250774600>
        <T_1250774590>3.5900000000e+01</T_1250774590>
        <T_1250774810>1.0000000000e-01</T_1250774810>
        <T_1250774700>8.0000000000e-01</T_1250774700>
        <T_1250774800>1.8000000000e+00</T_1250774800>
        <T_1250774690>3.6900000000e+01</T_1250774690>
        <T_1250774580>1.1900000000e+01</T_1250774580>
        <T_1250774790>3.3000000000e+00</T_1250774790>
        <T_1250774680>4.9500000000e+01</T_1250774680>
        <T_1250774570>3.1400000000e+01</T_1250774570>
        <T_1250774780>1.7000000000e+00</T_1250774780>
        <T_1250774670>2.5800000000e+01</T_1250774670>
        <T_1250774560>5.3000000000e+00</T_1250774560>
        <T_1250774770>1.9700000000e+01</T_1250774770>
        <T_1250774660>7.6000000000e+00</T_1250774660>
        <T_1250774550>1.0000000000e+00</T_1250774550>
        <T_1250774760>4.7600000000e+01</T_1250774760>
        <T_1250774650>3.1000000000e+01</T_1250774650>
        <T_1250774540>6.0000000000e-01</T_1250774540>
        <T_1250774750>2.0700000000e+01</T_1250774750>
        <T_1250774640>1.6000000000e+00</T_1250774640>
        <T_1250774530>4.0000000000e-01</T_1250774530>
        <T_1250774740>6.0000000000e-01</T_1250774740>
        <T_1250774630>2.8000000000e+00</T_1250774630>
        <T_1250774730>6.0000000000e-01</T_1250774730>
        <T_1250774620>2.6000000000e+00</T_1250774620>
        <T_1250774830>4.0000000000e-01</T_1250774830>
        <T_1250774720>7.0000000000e-01</T_1250774720>
        <T_1250774610>4.7000000000e+00</T_1250774610>
      </value>
    </cpu-user>
    <cpu-interrupt>
      <value>
        <T_1250774820>0.0000000000e+00</T_1250774820>
        <T_1250774710>0.0000000000e+00</T_1250774710>
        <T_1250774600>0.0000000000e+00</T_1250774600>
        <T_1250774590>1.0000000000e-01</T_1250774590>
        <T_1250774810>0.0000000000e+00</T_1250774810>
        <T_1250774700>0.0000000000e+00</T_1250774700>
        <T_1250774800>3.0000000000e-01</T_1250774800>
        <T_1250774690>0.0000000000e+00</T_1250774690>
        <T_1250774580>0.0000000000e+00</T_1250774580>
        <T_1250774790>0.0000000000e+00</T_1250774790>
        <T_1250774680>1.0000000000e-01</T_1250774680>
        <T_1250774570>0.0000000000e+00</T_1250774570>
        <T_1250774780>1.0000000000e-01</T_1250774780>
        <T_1250774670>0.0000000000e+00</T_1250774670>
        <T_1250774560>0.0000000000e+00</T_1250774560>
        <T_1250774770>1.0000000000e-01</T_1250774770>
        <T_1250774660>0.0000000000e+00</T_1250774660>
        <T_1250774550>0.0000000000e+00</T_1250774550>
        <T_1250774760>0.0000000000e+00</T_1250774760>
        <T_1250774650>0.0000000000e+00</T_1250774650>
        <T_1250774540>0.0000000000e+00</T_1250774540>
        <T_1250774750>0.0000000000e+00</T_1250774750>
        <T_1250774640>0.0000000000e+00</T_1250774640>
        <T_1250774530>0.0000000000e+00</T_1250774530>
        <T_1250774740>0.0000000000e+00</T_1250774740>
        <T_1250774630>0.0000000000e+00</T_1250774630>
        <T_1250774730>0.0000000000e+00</T_1250774730>
        <T_1250774620>0.0000000000e+00</T_1250774620>
        <T_1250774830>0.0000000000e+00</T_1250774830>
        <T_1250774720>0.0000000000e+00</T_1250774720>
        <T_1250774610>0.0000000000e+00</T_1250774610>
      </value>
    </cpu-interrupt>
  </cpu-0>
  <cpu-1>
    <cpu-system>
      <value>
        <T_1250774820>3.0000000000e-01</T_1250774820>
        <T_1250774710>1.0000000000e-01</T_1250774710>
        <T_1250774600>1.2000000000e+00</T_1250774600>
        <T_1250774590>2.3000000000e+00</T_1250774590>
        <T_1250774810>3.0000000000e-01</T_1250774810>
        <T_1250774700>1.0000000000e-01</T_1250774700>
        <T_1250774800>3.0000000000e-01</T_1250774800>
        <T_1250774690>8.1000000000e+00</T_1250774690>
        <T_1250774580>7.0000000000e-01</T_1250774580>
        <T_1250774790>1.1000000000e+00</T_1250774790>
        <T_1250774680>5.9000000000e+00</T_1250774680>
        <T_1250774570>1.2000000000e+00</T_1250774570>
        <T_1250774780>6.0000000000e-01</T_1250774780>
        <T_1250774670>8.4000000000e+00</T_1250774670>
        <T_1250774560>8.0000000000e-01</T_1250774560>
        <T_1250774770>5.0000000000e-01</T_1250774770>
        <T_1250774660>1.0000000000e+00</T_1250774660>
        <T_1250774550>4.0000000000e-01</T_1250774550>
        <T_1250774760>6.5000000000e+00</T_1250774760>
        <T_1250774650>2.2000000000e+00</T_1250774650>
        <T_1250774540>1.0000000000e-01</T_1250774540>
        <T_1250774750>1.0000000000e+00</T_1250774750>
        <T_1250774640>5.0000000000e-01</T_1250774640>
        <T_1250774530>1.0000000000e-01</T_1250774530>
        <T_1250774740>0.0000000000e+00</T_1250774740>
        <T_1250774630>7.0000000000e-01</T_1250774630>
        <T_1250774730>1.0000000000e-01</T_1250774730>
        <T_1250774620>9.0000000000e-01</T_1250774620>
        <T_1250774830>0.0000000000e+00</T_1250774830>
        <T_1250774720>3.0000000000e-01</T_1250774720>
        <T_1250774610>1.3000000000e+00</T_1250774610>
      </value>
    </cpu-system>
    <cpu-steal>
      <value>
        <T_1250774820>0.0000000000e+00</T_1250774820>
        <T_1250774710>0.0000000000e+00</T_1250774710>
        <T_1250774600>0.0000000000e+00</T_1250774600>
        <T_1250774590>0.0000000000e+00</T_1250774590>
        <T_1250774810>0.0000000000e+00</T_1250774810>
        <T_1250774700>0.0000000000e+00</T_1250774700>
        <T_1250774800>0.0000000000e+00</T_1250774800>
        <T_1250774690>0.0000000000e+00</T_1250774690>
        <T_1250774580>0.0000000000e+00</T_1250774580>
        <T_1250774790>0.0000000000e+00</T_1250774790>
        <T_1250774680>0.0000000000e+00</T_1250774680>
        <T_1250774570>0.0000000000e+00</T_1250774570>
        <T_1250774780>0.0000000000e+00</T_1250774780>
        <T_1250774670>0.0000000000e+00</T_1250774670>
        <T_1250774560>0.0000000000e+00</T_1250774560>
        <T_1250774770>0.0000000000e+00</T_1250774770>
        <T_1250774660>0.0000000000e+00</T_1250774660>
        <T_1250774550>0.0000000000e+00</T_1250774550>
        <T_1250774760>0.0000000000e+00</T_1250774760>
        <T_1250774650>0.0000000000e+00</T_1250774650>
        <T_1250774540>0.0000000000e+00</T_1250774540>
        <T_1250774750>0.0000000000e+00</T_1250774750>
        <T_1250774640>0.0000000000e+00</T_1250774640>
        <T_1250774530>0.0000000000e+00</T_1250774530>
        <T_1250774740>0.0000000000e+00</T_1250774740>
        <T_1250774630>0.0000000000e+00</T_1250774630>
        <T_1250774730>0.0000000000e+00</T_1250774730>
        <T_1250774620>0.0000000000e+00</T_1250774620>
        <T_1250774830>0.0000000000e+00</T_1250774830>
        <T_1250774720>0.0000000000e+00</T_1250774720>
        <T_1250774610>0.0000000000e+00</T_1250774610>
      </value>
    </cpu-steal>
    <cpu-nice>
      <value>
        <T_1250774820>0.0000000000e+00</T_1250774820>
        <T_1250774710>0.0000000000e+00</T_1250774710>
        <T_1250774600>0.0000000000e+00</T_1250774600>
        <T_1250774590>2.0000000000e-01</T_1250774590>
        <T_1250774810>0.0000000000e+00</T_1250774810>
        <T_1250774700>0.0000000000e+00</T_1250774700>
        <T_1250774800>0.0000000000e+00</T_1250774800>
        <T_1250774690>0.0000000000e+00</T_1250774690>
        <T_1250774580>0.0000000000e+00</T_1250774580>
        <T_1250774790>0.0000000000e+00</T_1250774790>
        <T_1250774680>0.0000000000e+00</T_1250774680>
        <T_1250774570>0.0000000000e+00</T_1250774570>
        <T_1250774780>0.0000000000e+00</T_1250774780>
        <T_1250774670>2.0000000000e-01</T_1250774670>
        <T_1250774560>0.0000000000e+00</T_1250774560>
        <T_1250774770>0.0000000000e+00</T_1250774770>
        <T_1250774660>0.0000000000e+00</T_1250774660>
        <T_1250774550>0.0000000000e+00</T_1250774550>
        <T_1250774760>0.0000000000e+00</T_1250774760>
        <T_1250774650>1.0000000000e-01</T_1250774650>
        <T_1250774540>0.0000000000e+00</T_1250774540>
        <T_1250774750>1.0000000000e-01</T_1250774750>
        <T_1250774640>0.0000000000e+00</T_1250774640>
        <T_1250774530>0.0000000000e+00</T_1250774530>
        <T_1250774740>0.0000000000e+00</T_1250774740>
        <T_1250774630>0.0000000000e+00</T_1250774630>
        <T_1250774730>0.0000000000e+00</T_1250774730>
        <T_1250774620>0.0000000000e+00</T_1250774620>
        <T_1250774830>0.0000000000e+00</T_1250774830>
        <T_1250774720>3.0000000000e-01</T_1250774720>
        <T_1250774610>0.0000000000e+00</T_1250774610>
      </value>
    </cpu-nice>
    <cpu-idle>
      <value>
        <T_1250774820>1.0120000000e+02</T_1250774820>
        <T_1250774710>1.0270000000e+02</T_1250774710>
        <T_1250774600>7.9700000000e+01</T_1250774600>
        <T_1250774590>8.1100000000e+01</T_1250774590>
        <T_1250774810>1.0120000000e+02</T_1250774810>
        <T_1250774700>8.3600000000e+01</T_1250774700>
        <T_1250774800>7.8700000000e+01</T_1250774800>
        <T_1250774690>2.1400000000e+01</T_1250774690>
        <T_1250774580>9.9200000000e+01</T_1250774580>
        <T_1250774790>8.4300000000e+01</T_1250774790>
        <T_1250774680>3.8600000000e+01</T_1250774680>
        <T_1250774570>9.4500000000e+01</T_1250774570>
        <T_1250774780>9.8300000000e+01</T_1250774780>
        <T_1250774670>1.5800000000e+01</T_1250774670>
        <T_1250774560>9.6800000000e+01</T_1250774560>
        <T_1250774770>9.8800000000e+01</T_1250774770>
        <T_1250774660>9.1400000000e+01</T_1250774660>
        <T_1250774550>9.8600000000e+01</T_1250774550>
        <T_1250774760>1.8000000000e+01</T_1250774760>
        <T_1250774650>8.5300000000e+01</T_1250774650>
        <T_1250774540>1.0120000000e+02</T_1250774540>
        <T_1250774750>9.7100000000e+01</T_1250774750>
        <T_1250774640>9.2400000000e+01</T_1250774640>
        <T_1250774530>1.0240000000e+02</T_1250774530>
        <T_1250774740>1.0220000000e+02</T_1250774740>
        <T_1250774630>7.9700000000e+01</T_1250774630>
        <limit>
          <maximum type="boolean">false</maximum>
          <value type="float">5.0</value>
        </limit>
        <T_1250774730>1.0460000000e+02</T_1250774730>
        <T_1250774620>9.3700000000e+01</T_1250774620>
        <T_1250774830>1.0290000000e+02</T_1250774830>
        <T_1250774720>1.0090000000e+02</T_1250774720>
        <T_1250774610>9.5100000000e+01</T_1250774610>
      </value>
    </cpu-idle>
    <cpu-softirq>
      <value>
        <T_1250774820>3.0000000000e-01</T_1250774820>
        <T_1250774710>1.0000000000e-01</T_1250774710>
        <T_1250774600>1.0000000000e+00</T_1250774600>
        <T_1250774590>9.0000000000e-01</T_1250774590>
        <T_1250774810>1.0000000000e-01</T_1250774810>
        <T_1250774700>3.0000000000e-01</T_1250774700>
        <T_1250774800>6.0000000000e-01</T_1250774800>
        <T_1250774690>1.1000000000e+00</T_1250774690>
        <T_1250774580>5.0000000000e-01</T_1250774580>
        <T_1250774790>2.0000000000e-01</T_1250774790>
        <T_1250774680>1.9000000000e+00</T_1250774680>
        <T_1250774570>9.0000000000e-01</T_1250774570>
        <T_1250774780>3.0000000000e-01</T_1250774780>
        <T_1250774670>2.2000000000e+00</T_1250774670>
        <T_1250774560>3.0000000000e-01</T_1250774560>
        <T_1250774770>5.0000000000e-01</T_1250774770>
        <T_1250774660>4.0000000000e-01</T_1250774660>
        <T_1250774550>2.0000000000e-01</T_1250774550>
        <T_1250774760>1.2000000000e+00</T_1250774760>
        <T_1250774650>1.0000000000e+00</T_1250774650>
        <T_1250774540>1.0000000000e-01</T_1250774540>
        <T_1250774750>5.0000000000e-01</T_1250774750>
        <T_1250774640>5.0000000000e-01</T_1250774640>
        <T_1250774530>1.0000000000e-01</T_1250774530>
        <T_1250774740>2.0000000000e-01</T_1250774740>
        <T_1250774630>6.0000000000e-01</T_1250774630>
        <T_1250774730>0.0000000000e+00</T_1250774730>
        <T_1250774620>6.0000000000e-01</T_1250774620>
        <T_1250774830>3.0000000000e-01</T_1250774830>
        <T_1250774720>5.0000000000e-01</T_1250774720>
        <T_1250774610>6.0000000000e-01</T_1250774610>
      </value>
    </cpu-softirq>
    <cpu-wait>
      <value>
        <T_1250774820>1.0000000000e-01</T_1250774820>
        <T_1250774710>0.0000000000e+00</T_1250774710>
        <T_1250774600>0.0000000000e+00</T_1250774600>
        <T_1250774590>5.1000000000e+00</T_1250774590>
        <T_1250774810>0.0000000000e+00</T_1250774810>
        <T_1250774700>2.0000000000e-01</T_1250774700>
        <T_1250774800>5.0000000000e-01</T_1250774800>
        <T_1250774690>1.4900000000e+01</T_1250774690>
        <T_1250774580>4.0000000000e-01</T_1250774580>
        <T_1250774790>1.5200000000e+01</T_1250774790>
        <T_1250774680>1.3400000000e+01</T_1250774680>
        <T_1250774570>2.0000000000e-01</T_1250774570>
        <T_1250774780>1.4000000000e+00</T_1250774780>
        <T_1250774670>2.8100000000e+01</T_1250774670>
        <T_1250774560>0.0000000000e+00</T_1250774560>
        <T_1250774770>0.0000000000e+00</T_1250774770>
        <T_1250774660>3.0000000000e-01</T_1250774660>
        <T_1250774550>1.8000000000e+00</T_1250774550>
        <T_1250774760>4.3000000000e+00</T_1250774760>
        <T_1250774650>1.0000000000e-01</T_1250774650>
        <T_1250774540>0.0000000000e+00</T_1250774540>
        <T_1250774750>0.0000000000e+00</T_1250774750>
        <T_1250774640>0.0000000000e+00</T_1250774640>
        <T_1250774530>0.0000000000e+00</T_1250774530>
        <T_1250774740>0.0000000000e+00</T_1250774740>
        <T_1250774630>5.7000000000e+00</T_1250774630>
        <T_1250774730>0.0000000000e+00</T_1250774730>
        <T_1250774620>6.6000000000e+00</T_1250774620>
        <T_1250774830>0.0000000000e+00</T_1250774830>
        <T_1250774720>1.1000000000e+00</T_1250774720>
        <T_1250774610>0.0000000000e+00</T_1250774610>
      </value>
    </cpu-wait>
    <cpu-user>
      <value>
        <T_1250774820>5.0000000000e-01</T_1250774820>
        <T_1250774710>3.0000000000e-01</T_1250774710>
        <T_1250774600>2.0000000000e+01</T_1250774600>
        <T_1250774590>1.3100000000e+01</T_1250774590>
        <T_1250774810>5.0000000000e-01</T_1250774810>
        <T_1250774700>1.7800000000e+01</T_1250774700>
        <T_1250774800>2.2700000000e+01</T_1250774800>
        <T_1250774690>5.6300000000e+01</T_1250774690>
        <T_1250774580>2.8000000000e+00</T_1250774580>
        <T_1250774790>4.0000000000e+00</T_1250774790>
        <T_1250774680>4.1800000000e+01</T_1250774680>
        <T_1250774570>5.2000000000e+00</T_1250774570>
        <T_1250774780>3.2000000000e+00</T_1250774780>
        <T_1250774670>4.7800000000e+01</T_1250774670>
        <T_1250774560>4.3000000000e+00</T_1250774560>
        <T_1250774770>2.8000000000e+00</T_1250774770>
        <T_1250774660>9.2000000000e+00</T_1250774660>
        <T_1250774550>1.3000000000e+00</T_1250774550>
        <T_1250774760>7.0600000000e+01</T_1250774760>
        <T_1250774650>1.4100000000e+01</T_1250774650>
        <T_1250774540>2.0000000000e-01</T_1250774540>
        <T_1250774750>5.0000000000e+00</T_1250774750>
        <T_1250774640>8.8000000000e+00</T_1250774640>
        <T_1250774530>3.0000000000e-01</T_1250774530>
        <T_1250774740>1.0000000000e-01</T_1250774740>
        <T_1250774630>1.6200000000e+01</T_1250774630>
        <T_1250774730>0.0000000000e+00</T_1250774730>
        <T_1250774620>2.9000000000e+00</T_1250774620>
        <T_1250774830>1.0000000000e-01</T_1250774830>
        <T_1250774720>8.0000000000e-01</T_1250774720>
        <T_1250774610>7.7000000000e+00</T_1250774610>
      </value>
    </cpu-user>
    <cpu-interrupt>
      <value>
        <T_1250774820>0.0000000000e+00</T_1250774820>
        <T_1250774710>0.0000000000e+00</T_1250774710>
        <T_1250774600>1.0000000000e-01</T_1250774600>
        <T_1250774590>1.0000000000e-01</T_1250774590>
        <T_1250774810>0.0000000000e+00</T_1250774810>
        <T_1250774700>0.0000000000e+00</T_1250774700>
        <T_1250774800>1.0000000000e-01</T_1250774800>
        <T_1250774690>1.0000000000e-01</T_1250774690>
        <T_1250774580>0.0000000000e+00</T_1250774580>
        <T_1250774790>0.0000000000e+00</T_1250774790>
        <T_1250774680>2.0000000000e-01</T_1250774680>
        <T_1250774570>1.0000000000e-01</T_1250774570>
        <T_1250774780>0.0000000000e+00</T_1250774780>
        <T_1250774670>2.0000000000e-01</T_1250774670>
        <T_1250774560>0.0000000000e+00</T_1250774560>
        <T_1250774770>0.0000000000e+00</T_1250774770>
        <T_1250774660>0.0000000000e+00</T_1250774660>
        <T_1250774550>0.0000000000e+00</T_1250774550>
        <T_1250774760>0.0000000000e+00</T_1250774760>
        <T_1250774650>0.0000000000e+00</T_1250774650>
        <T_1250774540>0.0000000000e+00</T_1250774540>
        <T_1250774750>1.0000000000e-01</T_1250774750>
        <T_1250774640>1.0000000000e-01</T_1250774640>
        <T_1250774530>0.0000000000e+00</T_1250774530>
        <T_1250774740>0.0000000000e+00</T_1250774740>
        <T_1250774630>0.0000000000e+00</T_1250774630>
        <T_1250774730>0.0000000000e+00</T_1250774730>
        <T_1250774620>0.0000000000e+00</T_1250774620>
        <T_1250774830>0.0000000000e+00</T_1250774830>
        <T_1250774720>0.0000000000e+00</T_1250774720>
        <T_1250774610>0.0000000000e+00</T_1250774610>
      </value>
    </cpu-interrupt>
  </cpu-1>
  <load>
    <load>
      <longterm>
        <T_1250774820>5.5000000000e-01</T_1250774820>
        <T_1250774710>5.9000000000e-01</T_1250774710>
        <T_1250774600>6.1000000000e-01</T_1250774600>
        <T_1250774590>6.0000000000e-01</T_1250774590>
        <T_1250774810>5.6000000000e-01</T_1250774810>
        <T_1250774700>6.0000000000e-01</T_1250774700>
        <T_1250774800>5.6000000000e-01</T_1250774800>
        <T_1250774690>6.1000000000e-01</T_1250774690>
        <T_1250774580>6.0000000000e-01</T_1250774580>
        <T_1250774790>5.6000000000e-01</T_1250774790>
        <T_1250774680>6.0000000000e-01</T_1250774680>
        <T_1250774570>5.9000000000e-01</T_1250774570>
        <T_1250774780>5.7000000000e-01</T_1250774780>
        <T_1250774670>5.9000000000e-01</T_1250774670>
        <T_1250774560>5.9000000000e-01</T_1250774560>
        <T_1250774770>5.7000000000e-01</T_1250774770>
        <T_1250774660>5.8000000000e-01</T_1250774660>
        <T_1250774550>6.0000000000e-01</T_1250774550>
        <T_1250774760>5.8000000000e-01</T_1250774760>
        <T_1250774650>5.8000000000e-01</T_1250774650>
        <T_1250774540>6.1000000000e-01</T_1250774540>
        <T_1250774750>5.7000000000e-01</T_1250774750>
        <T_1250774640>5.9000000000e-01</T_1250774640>
        <T_1250774530>6.1000000000e-01</T_1250774530>
        <T_1250774740>5.7000000000e-01</T_1250774740>
        <T_1250774630>5.9000000000e-01</T_1250774630>
        <limit>
          <maximum type="boolean">true</maximum>
          <value type="float">0.1</value>
        </limit>
        <T_1250774730>5.8000000000e-01</T_1250774730>
        <T_1250774620>6.0000000000e-01</T_1250774620>
        <T_1250774830>5.4000000000e-01</T_1250774830>
        <T_1250774720>5.9000000000e-01</T_1250774720>
        <T_1250774610>6.1000000000e-01</T_1250774610>
      </longterm>
      <shortterm>
        <T_1250774820>3.1000000000e-01</T_1250774820>
        <T_1250774710>5.7000000000e-01</T_1250774710>
        <T_1250774600>8.0000000000e-01</T_1250774600>
        <T_1250774590>5.9000000000e-01</T_1250774590>
        <T_1250774810>3.7000000000e-01</T_1250774810>
        <T_1250774700>6.7000000000e-01</T_1250774700>
        <T_1250774800>4.4000000000e-01</T_1250774800>
        <T_1250774690>7.9000000000e-01</T_1250774690>
        <T_1250774580>5.2000000000e-01</T_1250774580>
        <T_1250774790>3.3000000000e-01</T_1250774790>
        <T_1250774680>6.7000000000e-01</T_1250774680>
        <T_1250774570>4.3000000000e-01</T_1250774570>
        <T_1250774780>3.9000000000e-01</T_1250774780>
        <T_1250774670>5.2000000000e-01</T_1250774670>
        <T_1250774560>4.2000000000e-01</T_1250774560>
        <T_1250774770>4.6000000000e-01</T_1250774770>
        <T_1250774660>4.3000000000e-01</T_1250774660>
        <T_1250774550>5.0000000000e-01</T_1250774550>
        <T_1250774760>5.5000000000e-01</T_1250774760>
        <T_1250774650>4.3000000000e-01</T_1250774650>
        <T_1250774540>5.9000000000e-01</T_1250774540>
        <T_1250774750>3.7000000000e-01</T_1250774750>
        <T_1250774640>4.1000000000e-01</T_1250774640>
        <T_1250774530>7.0000000000e-01</T_1250774530>
        <T_1250774740>3.4000000000e-01</T_1250774740>
        <T_1250774630>4.8000000000e-01</T_1250774630>
        <limit>
          <maximum type="boolean">true</maximum>
          <value type="float">5.0</value>
        </limit>
        <T_1250774730>4.0000000000e-01</T_1250774730>
        <T_1250774620>5.7000000000e-01</T_1250774620>
        <T_1250774830>2.6000000000e-01</T_1250774830>
        <T_1250774720>4.8000000000e-01</T_1250774720>
        <T_1250774610>6.8000000000e-01</T_1250774610>
      </shortterm>
      <midterm>
        <T_1250774820>5.9000000000e-01</T_1250774820>
        <T_1250774710>7.4000000000e-01</T_1250774710>
        <T_1250774600>8.6000000000e-01</T_1250774600>
        <T_1250774590>8.2000000000e-01</T_1250774590>
        <T_1250774810>6.1000000000e-01</T_1250774810>
        <T_1250774700>7.6000000000e-01</T_1250774700>
        <T_1250774800>6.3000000000e-01</T_1250774800>
        <T_1250774690>7.9000000000e-01</T_1250774690>
        <T_1250774580>8.1000000000e-01</T_1250774580>
        <T_1250774790>6.2000000000e-01</T_1250774790>
        <T_1250774680>7.6000000000e-01</T_1250774680>
        <T_1250774570>8.1000000000e-01</T_1250774570>
        <T_1250774780>6.4000000000e-01</T_1250774780>
        <T_1250774670>7.4000000000e-01</T_1250774670>
        <T_1250774560>8.2000000000e-01</T_1250774560>
        <T_1250774770>6.6000000000e-01</T_1250774770>
        <T_1250774660>7.3000000000e-01</T_1250774660>
        <T_1250774550>8.5000000000e-01</T_1250774550>
        <T_1250774760>6.9000000000e-01</T_1250774760>
        <T_1250774650>7.4000000000e-01</T_1250774650>
        <T_1250774540>8.8000000000e-01</T_1250774540>
        <T_1250774750>6.6000000000e-01</T_1250774750>
        <T_1250774640>7.5000000000e-01</T_1250774640>
        <T_1250774530>9.1000000000e-01</T_1250774530>
        <T_1250774740>6.6000000000e-01</T_1250774740>
        <T_1250774630>7.7000000000e-01</T_1250774630>
        <T_1250774730>6.9000000000e-01</T_1250774730>
        <T_1250774620>8.0000000000e-01</T_1250774620>
        <T_1250774830>5.7000000000e-01</T_1250774830>
        <T_1250774720>7.1000000000e-01</T_1250774720>
        <T_1250774610>8.3000000000e-01</T_1250774610>
      </midterm>
    </load>
  </load>
</status>
EOX
    ret["status"].to_xml(:root => "status")
  end

  get '/security.xml' do
    ret = Hash.from_xml <<EOX
<security><ssh type="boolean">true</ssh><firewall type="boolean">true</firewall><firewall_after_startup type="boolean">false</firewall_after_startup></security>
EOX
    ret["security"].to_xml(:root => "security")
  end

  post '/security.xml' do
    security = { "ssh" => true, "firewall" => true, "firewall_after_startup" => false }
    security.to_xml(:root => "security")
  end

  get '/language.xml' do
    ret = Hash.from_xml <<EOX
<language><current>de_DE</current><utf8>true</utf8><rootlocale>ctype</rootlocale><available type="array"><language><id>zh_TW</id><name>ç¹é«ä¸­æ</name></language><language><id>tr_TR</id><name>Türkçe</name></language><language><id>ru_RU</id><name>Русский </name></language><language><id>ro_RO</id><name>Română</name></language><language><id>pl_PL</id><name>Polski</name></language><language><id>mk_MK</id><name>Македонски</name></language><language><id>fi_FI</id><name>Suomi</name></language><language><id>da_DK</id><name>Dansk</name></language><language><id>uk_UA</id><name>Українська</name></language><language><id>si_LK</id><name>සිංහල</name></language><language><id>nb_NO</id><name>Norsk</name></language><language><id>th_TH</id><name>ภาษาไทย</name></language><language><id>pt_PT</id><name>Português</name></language><language><id>nn_NO</id><name>Nynorsk</name></language><language><id>nl_NL</id><name>Nederlands</name></language><language><id>mr_IN</id><name>मराठी</name></language><language><id>lt_LT</id><name>Lietuvių</name></language><language><id>fr_FR</id><name>Français</name></language><language><id>es_ES</id><name>Español</name></language><language><id>en_US</id><name>English (US)</name></language><language><id>bs_BA</id><name>Bosanski</name></language><language><id>bg_BG</id><name>Български</name></language><language><id>ta_IN</id><name>தமிழ்</name></language><language><id>sv_SE</id><name>Svenska</name></language><language><id>sr_RS</id><name>Srpski</name></language><language><id>af_ZA</id><name>Afrikaans</name></language><language><id>zu_ZA</id><name>isiZulu</name></language><language><id>xh_ZA</id><name>isiXhosa</name></language><language><id>wa_BE</id><name>Walon</name></language><language><id>pt_BR</id><name>Português brasileiro</name></language><language><id>ko_KR</id><name>íê¸ </name></language><language><id>gu_IN</id><name>ગુજરાતી</name></language><language><id>ca_ES</id><name>Català</name></language><language><id>he_IL</id><name>עברית</name></language><language><id>et_EE</id><name>Eesti</name></language><language><id>el_GR</id><name>Ελληνικά </name></language><language><id>vi_VN</id><name>Tiếng Việt</name></language><language><id>km_KH</id><name>ខ្មែរ</name></language><language><id>cy_GB</id><name>Cymraeg</name></language><language><id>ka_GE</id><name>ქართული</name></language><language><id>ja_JP</id><name>�̦׈��</name></language><language><id>hr_HR</id><name>Hrvatski</name></language><language><id>hi_IN</id><name>हिन्दी</name></language><language><id>ar_EG</id><name>العربية</name></language><language><id>zh_CN</id><name>ᮮ᪝᪘ئ</name></language><language><id>sl_SI</id><name>Slovenščina</name></language><language><id>gl_ES</id><name>Galego</name></language><language><id>cs_CZ</id><name>Čeština</name></language><language><id>sk_SK</id><name>Slovenčina</name></language><language><id>it_IT</id><name>Italiano</name></language><language><id>id_ID</id><name>Bahasa Indonesia</name></language><language><id>hu_HU</id><name>Magyar</name></language><language><id>de_DE</id><name>Deutsch</name></language><language><id>pa_IN</id><name>ਪੰਜਾਬੀ</name></language><language><id>en_GB</id><name>English (UK)</name></language><language><id>bn_BD</id><name>বাংলা</name></language></available></language>
EOX
    ret["language"].to_xml(:root => "language")
  end

  post '/language.xml' do
    language = { "language" => "de_DE", "utf8" => true, "rootlocale" => "ctype" }
    language.to_xml(:root => "language")
  end

  get '/user/:id.xml' do
    user = {"id" =>"tux5", "cn" => "tux5",
            "groupname" => "users", "gid_number" => 0,
            "home_directory" => "/home/tux5", "login_shell" => "/bin/bash",
            "uid" => "tux5", "uid_number" => 1005,
            "type" => "local", "grouplist type" => [] }
    user.to_xml(:root => "user")
  end

  get '/user.xml' do
    ret = Hash.from_xml <<EOX
<users type="array">
  <user>
    <id>tuxtux</id>
    <cn>tux tux</cn>
    <groupname/>
    <gid_number type="integer"/>
    <home_directory/>
    <login_shell/>
    <uid>tuxtux</uid>
    <uid_number type="integer"/>
    <user_password/>
    <type>local</type>
    <grouplist type="array">
    </grouplist>
  </user>
  <user>
    <id>tux19</id>
    <cn>tux19</cn>
    <groupname/>
    <gid_number type="integer"/>
    <home_directory/>
    <login_shell/>
    <uid>tux19</uid>
    <uid_number type="integer"/>
    <user_password/>
    <type>local</type>
    <grouplist type="array">
    </grouplist>
  </user>
  <user>
    <id>tux2</id>
    <cn>Da Web Mastas</cn>
    <groupname/>
    <gid_number type="integer"/>
    <home_directory/>
    <login_shell/>
    <uid>tux2</uid>
    <uid_number type="integer"/>
    <user_password/>
    <type>local</type>
    <grouplist type="array">
    </grouplist>
  </user>
  <user>
    <id>tux5</id>
    <cn>tux5</cn>
    <groupname/>
    <gid_number type="integer"/>
    <home_directory/>
    <login_shell/>
    <uid>tux5</uid>
    <uid_number type="integer"/>
    <user_password/>
    <type>local</type>
    <grouplist type="array">
    </grouplist>
  </user>
</users>
EOX
    ret["users"].to_xml(:root => "users")
  end

