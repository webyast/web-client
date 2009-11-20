# Systemtime

#fills proxy with time parameters and set rest parameters to empty value
def fill_proxy_with_time(proxy,params)
  proxy.date = params[:date][:date]
  proxy.time = params[:currenttime]
end

#fills proxy with timezone parameters and set rest parameters to empty value
def fill_proxy_with_timezone(proxy,params,timezones)
  region = timezones.find { |reg| reg.name == params[:region] } || Hash.new

  tmz = region.entries.find { |e| e.name == params[:timezone]}
  proxy.timezone = tmz.id if tmz

  proxy.utcstatus = "UTC" #allways UTC see bnc#556467
end
