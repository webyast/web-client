require 'yast/service_resource'

class NetworkController < ApplicationController

  before_filter :login_required
  layout 'main'
  include ProxyLoader

  private
  def network_permissions
    @network = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.networks')
    unless @network
      flash[:notice] = _("Invalid session, please login again.")
      redirect_to( logout_path ) and return
    end
    @permissions = @network.permissions
  end
  
  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_network" 
  
  public
  def initialize
  end
  
  # GET /network
  def index
    @iface = "eth0"
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
    
    @name = hn.name
    @domain = hn.domain
    @nameservers = dns.nameservers
    @searchdomains = dns.searches

    @default_route = rt.via
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    return unless network_permissions
#    @user = @client.new( :id => :nil,
#      :no_home=>nil, 
#      :default_group=>nil, 
#      :new_login_name=>nil, 
#      :login_name=>nil, 
#      :groups=>[],
#      :grp_string=>nil,
#      :home_directory=>nil,
#      :full_name=>nil, 
#      :uid=>nil,
#      :sshkey=>nil, 
#      :new_uid=>nil, 
#      :login_shell=>"/bin/bash", 
#      :password=>nil,
#      :type=>"local", 
#      :id=>nil )
#    respond_to do |format|
#      format.html # new.html.erb
#      format.xml  { render :xml => @user }
#    end
  end

  # GET /users/1/edit
  def edit
    return unless network_permissions
    
    @network = @network.find(params[:id])
#    @user.type = ""
#    @user.id = @user.login_name
#    @user.grp_string = ""
#    counter = 0
#    @user.grp_string = ""
#    @user.groups.each do |group|
#       if counter == 0
#          @user.grp_string = group.id
#       else
#          @user.grp_string += ",#{group.id}"
#       end
#       counter += 1
#    end
  end



  # POST /users
  # POST /users.xml
  def create
    return unless client_permissions
    dummy = @client.new(params[:user])
    dummy.grp_string = params[:user][:grp_string] #do not know, why this will not be assigned in the constructor

    dummy.groups = []
    if dummy.grp_string != nil
       dummy.grp_string.split(",").each do |group|
          dummy.groups << { :id=>group.strip }
       end
    end
    @user = @client.new(:no_home=>params[:nohome],
                      :default_group=>dummy.default_group, 
                      :new_login_name=>nil, 
                      :login_name=>dummy.login_name, 
                      :groups=>dummy.groups,
                      :grp_string=>dummy.grp_string,
                      :home_directory=>dummy.home_directory,
                      :full_name=>dummy.full_name, 
                      :uid=>dummy.uid,
                      :sshkey=>nil, 
                      :new_uid=>nil, 
                      :login_shell=>dummy.login_shell, 
                      :password=>dummy.password,
                      :type=>"local")

    #Only UID greater than 1000 are allowed for local user
    response = true
    if @user.uid.to_i < 1000    
      response = false
    else
      begin
        response = @user.save
        rescue ActiveResource::ClientError => e
          flash[:error] = YaST::ServiceResource.error(e)
          response = false
      end
    end
    respond_to do |format|
      if response
        flash[:notice] = _('User was successfully created.')
        format.html { redirect_to(users_url) }
      else
        if @user.uid.to_i < 1000    
           #Only UID greater than 1000 are allowed for local user
           flash[:error] = _("UID: value >= 1000 is valid for local user only")
        end
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    return unless network_permissions
    @user = @client.find(params[:id])
    @user.new_login_name = nil
    @user.new_uid = nil
    @user.id = @user.login_name
    @user.default_group = params["user"]["default_group"]
    @user.groups = []
    if params["user"]["grp_string"] != nil
      @user.grp_string = params["user"]["grp_string"]
      params["user"]["grp_string"].split(",").each do |group|
        @user.groups << { :id=>group.strip }
      end
    end
    if @user.login_name != params["user"]["login_name"]
      @user.new_login_name = params["user"]["login_name"]
    end
    @user.home_directory = params["user"]["home_directory"]
    @user.full_name = params["user"]["full_name"]
    if @user.uid != params["user"]["uid"]
      @user.new_uid = params["user"]["uid"]
    end
    @user.login_shell = params["user"]["login_shell"]
    @user.password = params["user"]["password"]
    @user.type = "local"

    respond_to do |format|
      response = true
      begin
        response = @user.save
        rescue ActiveResource::ClientError => e
          flash[:error] = YaST::ServiceResource.error(e)
          response = false
      end
      if  response
        flash[:notice] = _('User was successfully updated.')
        format.html { redirect_to(users_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    return unless network_permissions
    @user = @client.find(params[:id])
    @user.id = @user.login_name
    @user.type = "local"
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
end
