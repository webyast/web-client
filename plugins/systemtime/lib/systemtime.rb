# Systemtime

def fill_proxy_with_time(proxy,params)
  arr = params[:date][:date].split("/")
    proxy.time = "#{arr[2]}-#{arr[0]}-#{arr[1]} - "+params[:currenttime]
    proxy.timezones = [] #not needed anymore
    proxy.utcstatus = ""
    proxy.timezone = ""
end

def fill_proxy_with_timezone(proxy,params,timezones)
  region = {}
    timezones.each do |reg|
      if reg.name == params[:region]
        region = reg
        break
      end
    end

    region.entries.each do |e|
      if (e.name == params[:timezone])
        t.timezone = e.id
        break
      end
    end

    if (proxy.utcstatus != "UTConly")
      if params[:utc] == "true"
        proxy.utcstatus = "UTC"
      else
        proxy.utcstatus = "localtime"
      end
    end

    proxy.time = ""
    proxy.timezones = [] #not needed anymore
end