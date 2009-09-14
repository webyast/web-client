require 'yast/service_resource'
require 'systemtime'


# = SystemTimeController
# Provides all functionality, that handles time management module.
# The most functionality around time handling is in rest-service and this
# controller just provide handling of different exceptions and UI features.
# Update time and timezone is separated as timezone update doesn't neccesarry
# require also time update and that could set time to bad value.
class SystemtimeController < ApplicationController
  before_filter :login_required
  layout 'main'
  include ProxyLoader

  #helpers
  private
  # Fills @+valid+ field that represents valid regions with informations from
  # @+timezone+ field.
  def fill_valid_timezones
    @valid = @@timezones.collect { |region| region.name }
  end

  # Fills current region name in field @+region+. Requires filled @+timezones+
  # and @+timezone+ fields
  # throws:: Exception if current timezone is not in any known region. @+region+
  # field in this case is +nil+.
  def fill_current_region   
    @region = @@timezones.find { |region|
      region.entries.find { |entry| entry.id==@timezone } }
    raise _("Unknown timezone #{@timezone} on host") unless @region
  end

  public

  # cannot move to initialize, it is not finded - http://www.yotabanana.com/hiki/ruby-gettext-howto-rails.html#ApplicationController
  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_systemtime"  # textdomain, options(:charset, :content_type)

  def initialize
    unless defined? @@timezones
      @@timezones = {}
    end
    @valid = []    
  end 

  # Index handler. Loads information from backend and if success all required
  # fields is filled. In case of errors redirect to help page, main page or just
  # show flash with partial problem.
  def index
    systemtime = load_proxy 'org.opensuse.yast.modules.yapi.time'

    unless systemtime      
      return false
    end

    unless @permissions[:read]
      logger.debug "No permissions for time module"
      flash[:warning] = _("No permissions for time module")
      redirect_to root_path
      return false
    end
        
    @@timezones = systemtime.timezones
    @timezone = systemtime.timezone
    @utcstatus = systemtime.utcstatus
    @time = systemtime.time
    @date = systemtime.date
    fill_valid_timezones
    begin
      fill_current_region
    rescue Exception => e
      flash[:warning] = e.message
      logger.warn e
      redirect_to root_path
    end
  end

  # Update time handler. Sets to backend new timezone and time.
  # If time is set to future it
  # still shows problems. Now it invalidate session for logged user.If
  # everything goes fine it redirect to index
  def update
    t = load_proxy 'org.opensuse.yast.modules.yapi.time'

    unless t
      return false
    end

    fill_proxy_with_timezone t, params, t.timezones
    #TODO for future change between init types
    fill_proxy_with_time t,params

    t.timezone = [] #save bandwitch

    begin
      t.save
      flash[:notice] = _('Settings have been written.')
    rescue Timeout::Error => e
      #do nothing as if you move time to future it throws this exception
      log.debug "Time moved to future"
      flash[:notice] = _('Settings have been written.')
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      logger.warn e
    rescue Exception => e
      flash[:error] = e.message
      logger.warn e
    end    

    redirect_success
  end


  #AJAX function that renders new timezones for selected region. Expected
  # initialized values from index call.
  def timezones_for_region
    if @@timezones.empty?
      # since while calling this function there is different instance of the class
      # than when calling index, @@timezones were empty; reinitialize them
      # possible FIXME: how does it increase the amount of data transferred?
      systemtime = load_proxy 'org.opensuse.yast.modules.yapi.time'
  
      unless systemtime
        return false  #possible FIXME: is returnign false for AJAX correct?
      end

      @@timezones = systemtime.timezones
    end

    region = @@timezones.find { |r| r.name == params[:value] } #possible FIXME later it gets class, not a string
    
    unless region
      return false; #possible FIXME: is returnign false for AJAX correct?
    end

    render(:partial => 'timezones',
      :locals => {:region => region, :default => region.central,
        :disabled => ! params[:disabled]=="true"})
  end
end
