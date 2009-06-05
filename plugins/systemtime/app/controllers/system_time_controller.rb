require 'yast/service_resource'

class SystemTimeController < ApplicationController
  before_filter :login_required
  layout 'main'

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_systemtime"  # textdomain, options(:charset, :content_type)
  def index
    set_permissions(controller_name)
    proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.time')
    @permissions = proxy.permissions

    begin
      @systemtime = proxy.find
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
    end

    # if time is not available
    if @systemtime.nil?
      render :template => 'shared/error_404'
      return
    end
logger.debug @systemtime.currenttime
    if @systemtime.is_utc == true
      @is_utc = "checked"
    else
      @is_utc = ""
    end

    @valid = []
    @systemtime.validtimezones::each do |s|
       @valid << s.id
    end
  end

  def commit_time
    proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.time')
    @permissions = proxy.permissions

    begin
      t = proxy.find
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
        redirect_to :action => :index
    end

    t.timezone = params[:timezone]
    if params[:utc] == "true"
       t.is_utc = true
    else
       t.is_utc = false
    end

    t.currenttime = params[:currenttime]
    arr = params[:date][0].split("/")
    t.date = Time.parse("#{arr[1]}/#{arr[0]}/#{arr[2]}").strftime("%m/%d/%y")
    t.validtimezones = [] #not needed anymore

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

end
