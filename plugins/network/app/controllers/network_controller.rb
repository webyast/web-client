class NetworkController < ApplicationController

  before_filter :login_required
  layout 'main'

  private

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_network" 

  public
  def initialize
  end
  
  NETMASK_RANGE = 0..32

  # GET /network
  def index
    @ifcs = Interface.find :all
    @iface = params[:interface]
    unless @iface
      ifc = @ifcs.find {|i| i.bootproto!=nil} || @ifcs[0]
      @iface = ifc.id
    end

    ifc = Interface.find @iface
    return false unless ifc

    # TODO use rescue_from "AR::Base not found..."
    # http://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html
    hn = Hostname.find :one
    return false unless hn

    dns = Dns.find :one
    return false unless dns

    rt = Route.find "default"
    return false unless rt

    # Only check permissions for one model, they should be the same
    # and it is a UI hint only
    # Can we also remove the resource lookups?
    @permissions = Interface.permissions

    # FIXME tests for YSRB

    @conf_mode = ifc.bootproto
    if @conf_mode == "static"
      ipaddr = ifc.ipaddr
    else
      ipaddr = "-/-"
    end
    @ip, @netmask = ipaddr.split "/"
    # when detect PREFIXLEN with leading "/"
    if ifc.bootproto == "static" && NETMASK_RANGE.include?(@netmask.to_i)
      @netmask = "/"+@netmask
    end    
 
    @name = hn.name
    @domain = hn.domain
    @nameservers = dns.nameservers
    @searchdomains = dns.searches
    @default_route = rt.via
    @conf_modes = {_("Not configured")=>"", _("Manual")=>"static", _("Automatic")=>"dhcp"}
    @conf_modes[@conf_mode] =@conf_mode unless @conf_modes.has_value? @conf_mode
    
  end



  # PUT /users/1
  # PUT /users/1.xml
  def update
    dirty = false
    rt = Route.find "default"
    return false unless rt
    dirty = true unless rt.via == params["default_route"]
    rt.via = params["default_route"]
    logger.info "dirty after default routing: #{dirty}"

    dns = Dns.find :one
    return false unless dns
    #compare empty array and nill cause true, so at first test emptyness
    #FIXME repair it when spliting of param is ready
    unless (dns.nameservers.empty? && params["nameservers"].blank?)
      dirty = true unless ( dns.nameservers == params["nameservers"])
    end
    unless (dns.searches.empty? && params["searchdomains"].blank?)
      dirty = true if (dns.searches == params["searchdomains"])
    end
    logger.info "dirty after  dns: #{dirty}"
# FIXME: params bellow should be arrays    
    dns.nameservers = params["nameservers"]#.split
    dns.searches    = params["searchdomains"]#.split

    hn = Hostname.find :one
    return false unless hn
    dirty = true unless (hn.name == params["name"] && hn.domain == params["domain"])
    logger.info "dirty after  hostname: #{dirty}"
    hn.name   = params["name"]
    hn.domain = params["domain"]

    ifc = Interface.find params["interface"]
    return false unless ifc
    dirty = true unless (ifc.bootproto == params["conf_mode"])
    logger.info "dirty after interface config: #{dirty}"
    ifc.bootproto=params["conf_mode"]
    if ifc.bootproto=="static"
      #ip addr is returned in another state then given, but restart of static address is not problem
      dirty = true
      ifc.ipaddr=params["ip"]+"/"+params["netmask"]
    end
   
    begin
      # this is not transaction!
      # if any *.save failed, the previous will be applied
      # FIXME JR: I think that if user choose dhcp not all settings should be written
      if dirty
        rt.save
        dns.save
        hn.save
        ifc.save
      end
#write to avoid confusion, with another string
      flash[:notice] = _('Network settings have been written.')
    rescue ActiveResource::ServerError => e
      response = Hash.from_xml(e.response.body)
      if ( response["error"] && response["error"]["type"]=="NETWORK_ROUTE_ERROR")
	flash[:error] = response["error"]["description"]
	logger.warn e
      else
        raise
      end
    end

    redirect_success
  end
end
