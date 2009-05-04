require 'yast/service_resource'

class SystemTimeController < ApplicationController
  before_filter :login_required
  layout 'main'

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_systemtime"  # textdomain, options(:charset, :content_type)

  def index
    set_permissions(controller_name)
    proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.time')

    @systemtime = proxy.find(:one)
    if @systemtime.is_utc == true
      @is_utc = "checked" 
    else 
      @is_utc = ""
    end
    @time_string = @systemtime.currenttime.strftime("%H:%M")
    @date_string = @systemtime.currenttime.strftime("%d/%m/%Y")
    
    @valid = []
    @systemtime.validtimezones::each do |s|   
       @valid << s.id
    end
  end

  def commit_time
    proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.time')
    t = proxy.find(:one)
    t.timezone = params[:timezone]
    if params[:utc] == "true"
       t.is_utc = true
    else
       t.is_utc = false
    end

    t.currenttime = DateTime.parse("#{params[:currentdate]} #{:currenttime}", "%d/%m/%Y %H:%M")
    
    t.validtimezones = [] #not needed anymore
    t.save
    if t.error_id != 0
       flash[:error] = t.error_string
       redirect_to :action => :index 
    else
       flash[:notice] = _('Settings have been written.')
       redirect_to :action => :index 
    end
  end

end
