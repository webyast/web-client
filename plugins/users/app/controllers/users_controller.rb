require 'yast/service_resource'

class UsersController < ApplicationController

  before_filter :login_required
  layout 'main'

  private
  def client_permissions
    @client = YaST::ServiceResource.proxy_for('org.opensuse.yast.modules.yapi.users')
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
  end

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_users"

  public
  def initialize
  end

  # GET /users
  # GET /users.xml
  def index
    return unless client_permissions
    @users = []
    begin
      @users = @client.find(:all)
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    return unless client_permissions
    @user = @client.new( :id => :nil,
      :groupname	=> nil,
      :cn		=> nil,
      :grouplist	=> {},
      :homeDirectory	=> nil,
      :cn		=> nil,
      :uid		=> nil,
      :uidNumber	=> nil,
      :sshkey		=> nil,
      :loginShell	=> "/bin/bash",
      :userPassword	=> nil,
      :type		=> "local",
      :id		=> nil
    )
    @user.grp_string = ""
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/exportssh
  def exportssh
    return unless client_permissions
    @user = @client.find(params[:id])
    @user.type = ""
    @user.id = @user.uid
    logger.debug "exportssh: #{@user.inspect}"
    respond_to do |format|
      format.html # exportssh.html.erb
      format.xml  { render :xml => @user, :location => "none" }
    end
  end

  # GET /users/1/edit
  def edit
    return unless client_permissions

    @user = @client.find(params[:id])

    @user.type	= ""
    @user.id	= @user.uid
    @user.grp_string = ""

    # FIXME hack, this must be done properly
    # (my keys in camelCase were transformed to under_scored)
    @user.uidNumber	= @user.uid_number
    @user.homeDirectory	= @user.home_directory
    @user.loginShell	= @user.login_shell
    @user.userPassword	= @user.user_password

    counter = 0
    @user.grouplist.each do |group|
       if counter == 0
          @user.grp_string = group.id
       else
          @user.grp_string += ",#{group.id}"
       end
       counter += 1
    end
  end

  # POST /users/1/sshexport
  def sshexport
    return unless client_permissions

    @user	= @client.find(params["user"]["uid"])
    @user.id	= @user.uid
    logger.debug "sshexportssh: #{@user.inspect}"
    @user.sshkey = params["user"]["sshkey"]
    response = true
    begin
      response = @user.save
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
        response = false
    end
    logger.debug "sshexportssh: #{response}"
    respond_to do |format|
      if response
        flash[:notice] = _('SSH-Key was successfully exported.')
        format.html { redirect_to(users_url) }
      else
        format.html { render :action => "exportssh" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
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
    @user = @client.new(
	:groupname	=> dummy.groupname,
        :uid		=> dummy.uid,
        :grouplist	=> dummy.grouplist,
#                      :grp_string=>dummy.grp_string,
        :homeDirectory	=> dummy.homeDirectory,
	:cn		=> dummy.cn,
        :uidNumber	=> dummy.uidNumber,
        :sshkey		=> nil,
        :loginShell	=> dummy.loginShell,
        :userPassword	=> dummy.userPassword,
        :type		=> "local"
    )

    #Only UID greater than 1000 are allowed for local user
    response = true
    if @user.uidNumber.to_i < 1000
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
        if @user.uidNumber.to_i < 1000
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
    return unless client_permissions
    @user = @client.find(params[:id])
    @user.id = @user.uid
    @user.groupname = params["user"]["groupname"]
    @user.grouplist = {}
#    if params["user"]["grp_string"] != nil
#      @user.grp_string = params["user"]["grp_string"]
#      params["user"]["grp_string"].split(",").each do |group|
#        @user.groups << { :id=>group.strip }
#      end
#    end
# FIXME solve renaming...
#    if @user.login_name != params["user"]["login_name"]
#      @user.new_login_name = params["user"]["login_name"]
#    end
#    if @user.uid != params["user"]["uid"]
#      @user.new_uid = params["user"]["uid"]
#    end
    @user.uidNumber	= params["user"]["uidNumber"]
    @user.homeDirectory = params["user"]["homeDirectory"]
    @user.cn = params["user"]["cn"]
    @user.loginShell = params["user"]["loginShell"]
    @user.userPassword = params["user"]["userPassword"]
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
    return unless client_permissions
    @user = @client.find(params[:id])
    @user.id = @user.uid
    @user.type = "local"
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
end
