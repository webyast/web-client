class Systemtime < ActiveResource::Base
  extend YastModel::Base
  model_interface :"org.opensuse.yast.modules.yapi.time"

  def region
    reg = self.timezones.find { |region|
      region.entries.find { |entry| entry.id==self.timezone } }
    raise _("Unknown timezone %s on host") % timezone unless reg
    return reg
  end

  def regions
    return @regions if @regions
    @regions = self.timezones.collect { |region| region.name }
  end

  def load_timezone(params)
    treg = self.timezones.find { |reg| reg.name == params[:region] } || Hash.new

    tmz = treg.entries.find { |e| e.name == params[:timezone]}
    self.timezone = tmz.id if tmz
    self.utcstatus = params[:utc] == "true"
  end

  def load_time(params)
    self.date = params[:date][:date]
    self.time = params[:currenttime]
  end

  def clear_time
    self.date = nil
    self.time = nil
  end
end
