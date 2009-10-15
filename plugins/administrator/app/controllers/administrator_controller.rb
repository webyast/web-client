require 'yast/service_resource'

class AdministratorController < ApplicationController
  before_filter :login_required

  private

  def client_permissions
    @client = YaST::ServiceResource.proxy_for('org.opensuse.yast.modules.yapi.administrator')
    unless @client
      flash[:notice] = _("Invalid session, please login again.")
      redirect_to( logout_path ) and return
    end
    @permissions = @client.permissions rescue {}
  end

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_administrator"  # textdomain, options(:charset, :content_type)

  public

  def index
    return unless client_permissions
    @administrator	= @client.find
    @administrator.confirm_password	= ""
  end

  # PUT
  def update
    return unless client_permissions
    @administrator	= @client.find

    admin	= params["administrator"]
    @administrator.password	= admin["password"]
    @administrator.aliases	= admin["aliases"]

    # validate data also here, if javascript in view is off
    if !admin["aliases"].empty?
      admin["aliases"].split(",").each do |mail|
	# only check emails, not local users
        if mail.include?("@") && mail !~ /(.+)@(.+)\.(.{2})/
          flash[:error] = _("Enter a valid e-mail address.")
          redirect_to :action => "index"
          return 
	end
      end
    end

    if admin["password"] != admin["confirm_password"]
      flash[:error] = _("Passwords do not match.")
      redirect_to :action => "index"
      return 
    end

    # only save selected subset of administrator data:
    if params.has_key? "save_aliases"
      @administrator.password	= nil
    elsif params.has_key? "save_password"
      @administrator.aliases	= nil
    end

    # we cannot pass empty string to rest-service
    @administrator.aliases = "NONE" if @administrator.aliases == ""

    begin
      response = @administrator.save
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
	logger.warn e.inspect
      # handle ADMINISTRATOR_ERROR in backend exception here, not by generic handler
      rescue ActiveResource::ServerError => e
	error = Hash.from_xml e.response.body
	logger.warn error.inspect
	if error["error"] && error["error"]["type"] == "ADMINISTRATOR_ERROR"
	  # %s is detailed error message
          flash[:error] = _("Error while saving administrator settings: %s") % error["error"]["output"]
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
