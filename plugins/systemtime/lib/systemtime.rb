# Systemtime

def fill_proxy_with_time(proxy,params)
  proxy.date = params[:date][:date]
  proxy.time = params[:currenttime]
  proxy.timezones = [] #not needed anymore
  proxy.utcstatus = ""
  proxy.timezone = ""
end

def fill_proxy_with_timezone(proxy,params,timezones)
  region = timezones.find { |reg| reg.name == params[:region] } || Hash.new


  tmz = region.entries.find { |e| e.name == params[:timezone]}
  proxy.timezone = tmz.id if tmz


  if (proxy.utcstatus != "UTConly")
    proxy.utcstatus = params[:utc] == "true" ? "UTC" : "localtime"
  end

  proxy.time = ""
  proxy.date = ""
  proxy.timezones = [] #not needed anymore
end