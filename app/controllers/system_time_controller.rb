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
    t = SystemTime.find(:one, :from => '/system/time', :element_name =>
    'system-time')
#render :xml => params
    t.systemtime = params[:systemtime]
    t.timezone = params[:timezone]
#    t.save
    redirect_to :action => :index
  end

end
