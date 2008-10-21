class SystemTimeController < ApplicationController
  before_filter :login_required
  layout 'main'
  def index
    @systemtime = SystemTime.find(:one, :from => '/systemtime.xml')
    if params[:last_error] && params[:last_error] != 0
       @systemtime.error_id = params[:last_error]
       if params[:last_error_string]
          @systemtime.error_string = params[:last_error_string]
       end
    end
    if @systemtime.is_utc == true
      @is_utc = "checked" 
    else 
      @is_utc = ""
    end
    @timeString = @systemtime.currenttime.hour.to_s
    @timeString << ":" 
    @timeString << @systemtime.currenttime.min.to_s
    @valid = []
    @validStrings = @systemtime.validtimezones.split(" ")
    @validStrings::each do |s|   
       @valid << s
    end
  end

  def commit_time
    t = SystemTime.find(:one, :from => '/systemtime.xml')
    t.timezone = params[:timezone]
    if params[:utc] == "true"
       t.is_utc = true
    else
       t.is_utc = false
    end
    timeArray = params[:currenttime].split ":"
    t.currenttime = DateTime.civil(params[:year].to_i, params[:month].to_i, 
                                   params[:day].to_i, timeArray[0].to_i, timeArray[1].to_i)
    t.validtimezones = "" #not needed anymore
    t.save
    if t.error_id != 0
       redirect_to :action => :index, :last_error_string =>t.error_string, :last_error =>t.error_id 
    else
       redirect_to :action => :index 
    end
  end

end
