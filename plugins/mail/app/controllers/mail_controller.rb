require 'yast/service_resource'

class MailController < ApplicationController
  before_filter :login_required

  private

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_mail"  # textdomain, options(:charset, :content_type)

  public

  def index
    @mail			= Mail.find :one
    @permissions		= Mail.permissions
    @mail.confirm_password	= @mail.password
    @mail.test_mail_address	= ""
    @mail.test_mail_address	= params["email"] if params.has_key? "email"
  end

  # PUT
  def update
    @mail			= Mail.find :one

    @mail.load params["mail"]

    # validate data also here, if javascript in view is off
    if @mail.password != @mail.confirm_password
      flash[:error] = _("Passwords do not match.")
      redirect_to :action => "index"
      return 
    end

    begin
      response = @mail.save
      notice	= _('Mail settings have been written.')
      unless @mail.test_mail_address.empty?
	notice += " " + _('Test mail was sent to %s.') % @mail.test_mail_address
      end
      flash[:notice] = notice
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
	logger.warn e.inspect
	redirect_to :action => "index"
	return
      rescue ActiveResource::ServerError => e
	error = Hash.from_xml e.response.body
	logger.warn error.inspect
	if error["error"] && error["error"]["type"] == "MAIL_SETTINGS_ERROR"
          flash[:error] = _("Error while saving mail settings: %s") % error["error"]["output"]
	else
	  raise e
	end
	redirect_to :action => "index"
	return
    end

    smtp_server	= params["mail"]["smtp_server"]

    # check if mail forwarning for root is configured
    if (smtp_server.nil? || smtp_server.empty?) &&
       # during initial workflow, only warn if administrator configuration does not follow
       !Basesystem.new.load_from_session(session).following_steps.any? { |h| h[:controller] == "administrator" }

      @administrator      = Administrator.find :one
      if @administrator && !@administrator.aliases.nil? && ! @administrator.empty?
	flash[:warning]	= _("No outgoing mail server is set, but administrator has mail forwarders defined.
Change %s<i>administrator</i>%s or %s<i>mail</i>%s configuration.") % ['<a href="/administrator">', '</a>', '<a href="/mail">', '</a>']
      end
    end
    if params.has_key?("send_mail")
      redirect_to :action => "index", :email => params["mail"]["test_mail_address"]
      return
    end
    redirect_success # redirect to next step
  end

end

# vim: ft=ruby
