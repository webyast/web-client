require 'yast/service_resource'


class SecuritiesController < ApplicationController
  before_filter :login_required

#  layout 'main' allready defined in application controller

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_securities"  # textdomain, options(:charset, :content_type)

  public

  # POST /security
  # POST /security.xml
  def create
    index
  end

  # GET /security
  # GET /security.xml
  def index
    set_permissions(controller_name)

    @client = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.security')
    @permissions = @client.permissions

    @write_permission = "disabled" unless @permissions[:write]

    @security = @client.find(:one, :from => '/security.xml') #Security.find(:one, :from => '/security.xml')

    @firewall_after_startup = "checked" if @security.firewall_after_startup
    @firewall = "checked" if @security.firewall
    @ssh = "checked" if @security.ssh
  end

  def commit #update
    client = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.security')

    s = client.find()
    s.firewall_after_startup = params[:firewall_after_startup].eql?("true")
    s.firewall = params[:firewall].eql?("true")
    s.ssh = params[:ssh].eql?("true")
    s.save()

    if s.error_id != 0
      flash[:error] = s.error_string
      redirect_to :action => :index  #???
#        redirect_to project_url(@security)
    else
      flash[:notice] = _('Settings have been written.')
      redirect_to :action => :index
#        redirect_to project_url(@security)
    end
  end
end

