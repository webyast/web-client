require 'yast/service_resource'


class SecuritiesController < ApplicationController
  before_filter :login_required, :prepare

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_securities"  # textdomain, options(:charset, :content_type)

  private

  def prepare
    @client = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.security')
    @permissions = @client.permissions
    set_permissions(controller_name)
  end

  public

  # POST /security
  # POST /security.xml
  def create
    @security = @client.find(:one, :from => '/security.xml')

    @firewall_on_startup = "checked" if @security.firewall_on_startup
    @firewall = "checked" if @security.firewall
    @ssh = "checked" if @security.ssh
  end

  # GET /security
  # GET /security.xml
  def show
  end

  def update
    s = @client.find()
    s.firewall_on_startup = params[:firewall_on_startup].eql?("true")
    s.firewall = params[:firewall].eql?("true")
    s.ssh = params[:ssh].eql?("true")

    response = true
    begin
      response = s.save # send to rest-service
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
        response = false
    end
    flash[:notice] = _("Settings have been written.") if response

    redirect_to root_url
  end
end

