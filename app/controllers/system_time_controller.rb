class SystemTimeController < ApplicationController
  layout 'main'
  def index
    t = SystemTime.find(:one, :from => '/system/systemtime')
    @systemtime = t.time
    @timezone = t.timezone
    if t.isUTC=="true"
      @is_utc = "checked" 
    else 
      @is_utc = ""
    end
  end

  def commit_time
    t = SystemTime.find(:one, :from => '/system/systemtime')
#render :xml => params
    t.time = params[:systemtime]
    t.timezone = params[:timezone]
    if params[:utc] == "true"
       t.isUTC = true
    else
       t.isUTC = false
    end
    t.save
    redirect_to :action => :index
  end

end
