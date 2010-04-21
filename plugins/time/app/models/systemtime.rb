#--
# Copyright (c) 2009-2010 Novell, Inc.
# 
# All Rights Reserved.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
# 
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#++

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
