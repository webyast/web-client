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
    @valid.clear
    @timezones.each do |region|
      @valid.push(region.name)
    end
  end

  def fill_current_region
    @timezones.each do |region|
      region.entries.each do |entry|
        if entry.id == @timezone
          @region = region
          return
        end
      end
    end
    raise _("Unknown timezone #{@timezone} on host")
  end

  public

  # cannot move to initialize, it is not finded - http://www.yotabanana.com/hiki/ruby-gettext-howto-rails.html#ApplicationController
  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_systemtime"  # textdomain, options(:charset, :content_type)

  def initialize
    @timezones = {}
    @valid = []    
  end 

  def index    
    systemtime = load_proxy 'org.opensuse.yast.modules.yapi.time'

    unless systemtime      
      return false
    end

    unless @permissions[:read]
      flash[:warning] = "No permissions for time module"
      redirect_to root_path
      return false
    end

        
    @timezones = systemtime.timezones
    @timezone = systemtime.timezone
    @utcstatus = systemtime.utcstatus
    @time = systemtime.time
    @date = systemtime.date
    fill_valid_timezones
    begin
      fill_current_region
    rescue Exception => e
      flash[:warning] = e.message
      ExceptionLogger.log_exception e
      redirect_to root_path
    end
  end

  def update_time
    t = load_proxy 'org.opensuse.yast.modules.yapi.time'

    # FIXME: add a 'redirect_to'
    unless t
      return false
    end

    fill_proxy_with_time t,params

    begin
      t.save
      flash[:notice] = _('Settings have been written.')
    rescue Timeout::Error => e
      #do nothing as if you move time to future it throws this exception
      log.debug "Time moved to future" 
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      ExceptionLogger.log_exception e
    rescue Exception => e
      flash[:error] = e.message
      ExceptionLogger.log_exception e
    end    

    redirect_to :action => :index
  end

  def update_timezone
    t = load_proxy 'org.opensuse.yast.modules.yapi.time'

    # FIXME: add a 'redirect_to'
    unless t
      return false
    end

    fill_proxy_with_timezone t,params, t.timezones
    
    begin
      t.save
      flash[:notice] = _('Settings have been written.')
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      ExceptionLogger.log_exception e
    rescue Exception => e
      flash[:error] = e.message
      ExceptionLogger.log_exception e
    end

    redirect_to :action => :index    
  end

  def timezones_for_region
    region = ""
    @timezones.each do |r|
      if r.name == params[:value]
        region = r
      end
    end
    render(:partial => 'timezones',
      :locals => {:region => region, :default => region.central,
        :disabled => ! params[:disabled]=="true"})
  end
end
