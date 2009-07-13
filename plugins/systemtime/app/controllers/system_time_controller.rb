require 'yast/service_resource'

class SystemTimeController < ApplicationController
  before_filter :login_required
  layout 'main'

  #helpers
  private
  def fill_valid_timezones
    @@timezones.each do |region|
      @valid.push(region.name)
    end
  end

  def fill_current_region
    @@timezones.each do |region|
      region.entries.each do |entry|
        if entry.id == @systemtime.timezone
          @region = region
        end
      end
    end
  end

  def fill_date_and_time (timedate)
    @time = timedate[timedate.index(" - ")+3,8]
    @date = timedate[0..timedate.index(" - ")-1]
    #convert date to format for datepicker
    @date.sub!(/^(\d+)-(\d+)-(\d+)/,'\3/\2/\1')
  end

  public
  @@timezones = {}

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_systemtime"  # textdomain, options(:charset, :content_type)

  def index
    proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.modules.yapi.time')
    @permissions = proxy.permissions

    begin
      @systemtime = proxy.find
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
    rescue Exception => e
      flash[:error] = e
    end

    # if time is not available
    unless @systemtime
      redirect_to "/404"
      return
    end

    @valid = []    
    @@timezones = @systemtime.timezones
    fill_valid_timezones
    fill_current_region
    fill_date_and_time(@systemtime.time)
  end

  def commit_time
    proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.modules.yapi.time')
    @permissions = proxy.permissions
    begin
      t = proxy.find
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      redirect_to :action => :index
    end
    
    arr = params[:date][:date].split("/")
    t.time = "#{arr[2]}-#{arr[0]}-#{arr[1]} - "+params[:currenttime]
    t.timezones = [] #not needed anymore
    t.utcstatus = ""
    t.timezone = ""

    response = true
    begin
      response = t.save
    rescue Timeout::Error => e
      #do nothing as if you move time to future it throws this exception
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      response = false
    end
    if response
      flash[:notice] = _('Settings have been written.')
      redirect_to :action => :index
    else
      
      redirect_to :action => :index
    end
  end

  def commit_timezone
    proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.modules.yapi.time')
    @permissions = proxy.permissions

    begin
      t = proxy.find
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      redirect_to :action => :index
    end

    region = {}
    @@timezones.each do |reg|
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

    if (t.utcstatus != "UTConly")
      if params[:utc] == "true"
        t.utcstatus = "UTC"
      else
        t.utcstatus = "localtime"
      end
    end

    t.time = ""
    t.timezones = [] #not needed anymore

    response = true
    begin
      response = t.save
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      response = false
    end
    if !response
      redirect_to :action => :index
    else
      flash[:notice] = _('Settings have been written.')
      redirect_to :action => :index
    end
  end

  def timezones_for_region
    region = ""
    @@timezones.each do |r|
      if r.name == params[:value]
        region = r
      end
    end
    render(:partial => 'timezones',
      :locals => {:region => region, :default => region.central,
        :disabled => ! params[:disabled]=="true"})
  end
end
