class SystemTimeController < ApplicationController
  before_filter :login_required
  layout 'main'
  def index
    set_permissions(controller_name)

    @systemtime = SystemTime.find(:one, :from => '/systemtime.xml')
    if @systemtime.is_utc == true
      @is_utc = "checked" 
    else 
      @is_utc = ""
    end
    @time_string = @systemtime.currenttime.hour.to_s
    @time_string << ":" 
    @time_string << @systemtime.currenttime.min.to_s
    @valid = []
    @valid_strings = @systemtime.validtimezones.split(" ")
    @valid_strings::each do |s|   
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
    time_array = params[:currenttime].split ":"
    t.currenttime = DateTime.civil(params[:year].to_i, params[:month].to_i, 
                                   params[:day].to_i, time_array[0].to_i, time_array[1].to_i)
    t.validtimezones = "" #not needed anymore
    t.save
    if t.error_id != 0
       flash[:error] = t.error_string
       redirect_to :action => :index 
    else
       flash[:notice] = 'Settings have been written.'
       redirect_to :action => :index 
    end
  end

end
