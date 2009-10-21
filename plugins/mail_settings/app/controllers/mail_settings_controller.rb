require 'yast/service_resource'

class MailSettingsController < ApplicationController
  before_filter :login_required
  include ProxyLoader

  private

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_mail_settings"  # textdomain, options(:charset, :content_type)

  public

  def index
    @mail_settings	= load_proxy 'org.opensuse.yast.modules.yapi.mailsettings'
    return unless @mail_settings
    @mail_settings.confirm_password	= @mail_settings.password
  end

  # PUT
  def update
    @mail_settings	= load_proxy 'org.opensuse.yast.modules.yapi.mailsettings'
    return unless @mail_settings

    @mail_settings.load params["mail_settings"]

    # validate data also here, if javascript in view is off
    if @mail_settings.password != @mail_settings.confirm_password
      flash[:error] = _("Passwords do not match.")
      redirect_to :action => "index"
      return 
    end

    begin
      response = @mail_settings.save
      flash[:notice] = _('Mail settings have been written.')
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
	logger.warn e.inspect
      rescue ActiveResource::ServerError => e
	error = Hash.from_xml e.response.body
	logger.warn error.inspect
	if error["error"] && error["error"]["type"] == "MAIL_SETTINGS_ERROR"
          flash[:error] = _("Error while saving mail settings: %s") % error["error"]["output"]
	else
	  raise e
	end
    end

    if params.has_key? "commit"
      redirect_success # redirect to next step
    else
      redirect_to :action => "index"
    end
  end

end

# vim: ft=ruby
