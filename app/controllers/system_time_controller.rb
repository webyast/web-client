require 'systemtime'

class SystemTimeController < ApplicationController
  layout 'main'
  def index
    t = SystemTime.find(:one, :from => '/system/time', :element_name => 'system-time')
    @systemtime = t.systemtime
    @timezone = t.timezone
    if t.is_utc=true
      @is_utc = "checked" 
    else 
      @is_utc = ""
    end
  end

  def commit_time
#    t = SystemTime.find(:one, :from => '/system/time', :element_name =>
#    'system-time')
 render :text =>  request.path_parameters.to_s
#    t.systemtime = params[systemtime]
#    t.timezone = params[timezone]
#    t.save
#    redirect_to :action => :index
  end

end
