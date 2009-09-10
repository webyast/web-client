require 'yast/service_resource'

class NetworkController < ApplicationController

  before_filter :login_required
  layout 'main'
  include ProxyLoader
  
  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_network" 

  private
  def network_permissions
    @client = YaST::ServiceResource.proxy_for('org.opensuse.yast.modules.yapi.network')
    unless @client
      # FIXME: check the reason why proxy_for failed, i.e.
      # - no server known
      # - no permission to connect to server
      # - server does not provide interface
      # - server does not respond (timeout, etc.)
      # - invalid session
      flash[:notice] = _("Invalid session, please login again.")
      redirect_to( logout_path ) and return
    end

    @permissions = @client.permissions
    @ifcs = load_proxy "org.opensuse.yast.modules.yapi.network.interfaces", :all
    @iface = params[:interface] || @ifcs[0].id

    ifc = load_proxy "org.opensuse.yast.modules.yapi.network.interfaces", @iface
    return false unless ifc

    hn = load_proxy "org.opensuse.yast.modules.yapi.network.hostname"
    return false unless hn

    dns = load_proxy "org.opensuse.yast.modules.yapi.network.dns"
    return false unless dns

    rt = load_proxy "org.opensuse.yast.modules.yapi.network.routes", "default"
    return false unless rt

#    # FIXME mixed up by multiple load_proxy
#    unless @permissions[:read]
#      flash[:warning] = _("No permissions for network module")
#      redirect_to root_path
#      return false
#    end
#
 
    @conf_mode = ifc.bootproto
    if @conf_mode == "static"
      ipaddr = ifc.ipaddr
    else
      ipaddr = "-/-"
    end
    @ip, @netmask = ipaddr.split "/"
    
    @name = hn.name
    @domain = hn.domain
    @nameservers = dns.nameservers
    @searchdomains = dns.searches

    @default_route = rt.via

#    @network = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.network')
#    unless @network
#      flash[:notice] = _("Invalid session, please login again.")
#      redirect_to( logout_path ) and return
#    end
  end
  
  public
  def initialize
  end
  
  # GET /network
  def index
    return unless network_permissions
    @networks = []
    begin
      @networks = @client.find(:all)
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @networks }
    end
  end

  # GET /users/1/edit
  def edit
  end


  # PUT /users/1
  # PUT /users/1.xml
  def update
     rt = load_proxy "org.opensuse.yast.modules.yapi.network.routes", "default"
    unless rt
      return false
    end

    rt.via = params["default_route"]
#    fill_proxy_with_time t,params

    begin
      rt.save
      flash[:notice] = _('Settings have been written.')
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      logger.warn e
    rescue Exception => e
      flash[:error] = e.message
      logger.warn e
    end    

#    redirect_to :action => :index    
#    index
    redirect_to :action => 'index'
  end
end
