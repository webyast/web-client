require 'yast/service_resource'

class MailController < ApplicationController
  before_filter :login_required
  include ProxyLoader

  private

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_mail"  # textdomain, options(:charset, :content_type)

  public

  def index
    @mail	= load_proxy 'org.opensuse.yast.modules.yapi.mailsettings'
    return unless @mail
    @mail.confirm_password	= @mail.password
  end

  # PUT
  def update
    @mail	= load_proxy 'org.opensuse.yast.modules.yapi.mailsettings'
    return unless @mail

    @mail.load params["mail"]

    # validate data also here, if javascript in view is off
    if @mail.password != @mail.confirm_password
      flash[:error] = _("Passwords do not match.")
      redirect_to :action => "index"
      return 
    end

    begin
      response = @mail.save
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

    # check if mail forwarning for root is configured
    if @mail.smtp_server.nil? || @mail.smtp_server.empty?
      @administrator      = load_proxy 'org.opensuse.yast.modules.yapi.administrator'
      if @administrator && !@administrator.aliases.nil? && ! @administrator.empty?
	flash[:error]	= _("No outgoing mail server is set, but administrator has mail forwarders defined. Forwarding mails cannot work.")
      end
    end
    redirect_success # redirect to next step
  end

end

# vim: ft=ruby
