require 'yast/service_resource'
require 'systemtime'

# FIXME: add comments to explain functions

class SystemTimeController < ApplicationController
  before_filter :login_required
  layout 'main'
  include ProxyLoader

  #helpers
  private
  def fill_valid_timezones
    @@timezones.each do |region|
      @valid.push(region.name)
    end
  end

  def fill_current_region
    # FIXME: @region can remain unset
    @@timezones.each do |region|
      region.entries.each do |entry|
        if entry.id == @systemtime.timezone
          @region = region
        end
      end
    end
  end

  def fill_date_and_time (timedate)
    # FIXME: such conversions should be in a model
    @time = timedate[timedate.index(" - ")+3,8]
    @date = timedate[0..timedate.index(" - ")-1]
    #convert date to format for datepicker
    @date.sub!(/^(\d+)-(\d+)-(\d+)/,'\3/\2/\1')
  end

  public
  
  # FIXME: should go to initialize()
  @@timezones = {}

  # FIXME: should go to initialize()
  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_systemtime"  # textdomain, options(:charset, :content_type)

  def index    
    @systemtime = load_proxy 'org.opensuse.yast.modules.yapi.time'

    unless @systemtime      
      return false
    end

    unless @permissions[:read]
      flash[:warning] = "No permissions for time module"
      redirect_to root_path
      return false
    end

    @valid = []    
    @@timezones = @systemtime.timezones
    fill_valid_timezones
    fill_current_region
    fill_date_and_time(@systemtime.time)
  end

  # FIXME: rename to 'update' to match rails conventions
  def commit_time
    t = load_proxy 'org.opensuse.yast.modules.yapi.time'

    # FIXME: add a 'redirect_to'
    unless t
      return false
    end

    fill_proxy_with_time t,params

    begin
      response = t.save
      flash[:notice] = _('Settings have been written.')
    rescue Timeout::Error => e
      #do nothing as if you move time to future it throws this exception
      log.debug "Time moved to future" 
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      log_exception e
    #FIXME: what about other exceptions ?
    end    

    redirect_to :action => :index
  end

  # FIXME: rename to 'update' to match rails conventions
  def commit_timezone
    t = load_proxy 'org.opensuse.yast.modules.yapi.time'

    # FIXME: add a 'redirect_to'
    unless t
      return false
    end

    fill_proxy_with_time t,params,@@systemtime
    
    begin
      response = t.save
      flash[:notice] = _('Settings have been written.')
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      log_exception e
    #FIXME: what about other exceptions ?
    end

    redirect_to :action => :index    
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
