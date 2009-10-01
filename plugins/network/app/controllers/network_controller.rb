require 'yast/service_resource'

class NetworkController < ApplicationController

  before_filter :login_required
  layout 'main'
  include ProxyLoader
  
  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_network" 

  public
  def initialize
  end
  
  NETMASK_RANGE = 0..32

  # GET /network
  def index

    @ifcs = load_proxy "org.opensuse.yast.modules.yapi.network.interfaces", :all
    @iface = params[:interface]
    unless @iface
      ifc = @ifcs.find {|i| i.bootproto!=nil} || @ifcs[0]
      @iface = ifc.id
    end

    ifc = load_proxy "org.opensuse.yast.modules.yapi.network.interfaces", @iface
    return false unless ifc

    hn = load_proxy "org.opensuse.yast.modules.yapi.network.hostname"
    return false unless hn

    dns = load_proxy "org.opensuse.yast.modules.yapi.network.dns"
    return false unless dns

    rt = load_proxy "org.opensuse.yast.modules.yapi.network.routes", "default"
    return false unless rt


    # FIXME mixed up by multiple load_proxy
    unless @permissions[:read]
      flash[:warning] = _("No permissions for network module")
      redirect_to root_path
      return false
    end
 
    @conf_mode = ifc.bootproto
    if @conf_mode == "static"
      ipaddr = ifc.ipaddr
    else
      ipaddr = "-/-"
    end
    @ip, @netmask = ipaddr.split "/"
    # when detect PREFIXLEN with leading "/"
    if ifc.bootproto == "static" && NETMASK_RANGE.include?(netmask.to_i)
      @netmask = "/"+@netmask
    end    
#    @netmask = "/"+@netmask if ifc.bootproto == "static" && @netmask.to_i >= 0 && @netmask.to_i <= 32
 
    @name = hn.name
    @domain = hn.domain
    @nameservers = dns.nameservers
    @searchdomains = dns.searches
    @default_route = rt.via
    @conf_modes = {""=>"", _("static")=>"static", _("dhcp")=>"dhcp"}
    @conf_modes[@conf_mode] =@conf_mode unless @conf_modes.has_value? @conf_mode
    
  end



  # PUT /users/1
  # PUT /users/1.xml
  def update
    rt = load_proxy "org.opensuse.yast.modules.yapi.network.routes", "default"
    return false unless rt
    rt.via = params["default_route"]

    dns = load_proxy "org.opensuse.yast.modules.yapi.network.dns"
    return false unless dns
# FIXME: params bellow should be arrays    
    dns.nameservers = params["nameservers"]#.split
    dns.searches    = params["searchdomains"]#.split

    hn = load_proxy "org.opensuse.yast.modules.yapi.network.hostname"
    return false unless hn
    hn.name   = params["name"]
    hn.domain = params["domain"]

    ifc = load_proxy "org.opensuse.yast.modules.yapi.network.interfaces", params["interface"]
    return false unless ifc
    ifc.bootproto=params["conf_mode"]
    if ifc.bootproto=="static"
      ifc.ipaddr=params["ip"]+"/"+params["netmask"]
    end
    
    begin
      # this is not transaction!
      # if any *.save failed, the previous will be applied
      rt.save
      dns.save
      hn.save
      ifc.save
      flash[:notice] = _('Settings have been written.')
    rescue ActiveResource::ServerError => e
      response = Hash.from_xml(e.response.body)
      if ( response["error"] && response["error"]["type"]=="NETWORK_ROUTE_ERROR")
	flash[:error] = response["error"]["description"]
	logger.warn e
      else
         throw e
      end
    rescue Exception => e
      flash[:error] = e.message
      logger.warn e
    end    

    redirect_to :action => 'index'
  end
end
