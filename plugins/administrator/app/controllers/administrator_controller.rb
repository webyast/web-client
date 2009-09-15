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
  end

  # PUT
  def update
    return unless client_permissions
    @administrator	= @client.find

    admin	= params["administrator"]
    @administrator.password	= admin["password"]
    @administrator.aliases	= admin["aliases"]

    # only save selected subset of administrator data:
    if params.has_key? "save_aliases"
      @administrator.password	= nil
    elsif params.has_key? "save_password"
      @administrator.aliases	= nil
    end

    begin
      response = @administrator.save
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
    end

    if params.has_key? "commit"
      redirect_success # redirect to next step
    else
      redirect_to :action => "index"
    end
  end

end

# vim: ft=ruby
