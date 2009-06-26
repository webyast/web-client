class ConfigNtpController < ApplicationController
  before_filter :login_required
  layout 'main'

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_services"  # textdomain, options(:charset, :content_type)

  def show
    @client = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.services')
    @permissions = @client.permissions

    @ntp = ConfigNtp.find(:one, :from => '/services/ntp/config.xml')
    logger.debug "ConfigNtp: #{@ntp.inspect}"

    if @ntp.enabled == true
      @is_enabled = "checked"
    else
      @is_enabled = ""
    end
    if @ntp.use_random_server == true
      @is_use_random_server = "checked"
    else
      @is_use_random_server = ""
    end
  end

  def create
    @ntp = ConfigNtp.find(:one, :from => '/services/ntp/config.xml')
    logger.debug "ConfigNtp: #{@ntp.inspect}"
    logger.debug "Changing to #{params.inspect}"
    @ntp.manual_server = params[:manual_server]
    if params[:enabled] == "true"
       @ntp.enabled = true
    else
       @ntp.enabled = false
    end
    if params[:use_random_server] == "true"
       @ntp.use_random_server = true
    else
       @ntp.use_random_server = false
    end
    @ntp.id = "ntp"
    response = @ntp.put(:config, {}, @ntp.to_xml)
    retNtp = Hash.from_xml(response.body)
    if retNtp["config_ntp"]["error_id"] != 0
       flash[:error] = retNtp["config_ntp"]["error_string"]
    else
        flash[:notice] = _("Settings have been written.")
    end
    redirect_to :action => :show
  end

end
