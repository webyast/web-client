class SystemTimeController < ApplicationController
  layout 'main'
  def index
    t = SystemTime.find(:one, :from => '/system/systemtime')
    @systemtime = t.systemtime
    @timezone = t.timezone
    if t.is_utc == true
      @is_utc = "checked" 
    else 
      @is_utc = ""
    end
  end

  def commit_time
    t = SystemTime.find(:one, :from => '/system/systemtime')
    t.id = "systemtime"
    t.systemtime = params[:systemtime]
    t.timezone = params[:timezone]
    if params[:utc] == "true"
       t.is_utc = true
    else
       t.is_utc = false
    end
    t.save
    redirect_to :action => :index
  end

end
