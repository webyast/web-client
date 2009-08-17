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
      :home_directory	=> nil,
      :cn		=> nil,
      :uid		=> nil,
      :uid_number	=> nil,
      :login_shell	=> "/bin/bash",
      :user_password	=> nil,
      :type		=> "local",
      :id		=> nil
    )
    @user.grp_string = ""
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
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
    @user.uid_number	= @user.uid_number
    @user.home_directory	= @user.home_directory
    @user.login_shell	= @user.login_shell
    @user.user_password	= @user.user_password

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


  # POST /users
  # POST /users.xml
  def create
    return unless client_permissions
    dummy = @client.new(params[:user])
    dummy.grp_string = params[:user][:grp_string] #do not know, why this will not be assigned in the constructor

    dummy.grouplist = {}
    if dummy.grp_string != nil
       dummy.grp_string.split(",").each do |group|
          dummy.grouplist[group.strip]	= 1
       end
    end

    @user = @client.new(
	:groupname	=> dummy.groupname,
        :uid		=> dummy.uid,
        :grouplist	=> dummy.grouplist,
        :home_directory	=> dummy.home_directory,
	:cn		=> dummy.cn,
        :uid_number	=> dummy.uid_number,
        :login_shell	=> dummy.login_shell,
        :user_password	=> dummy.user_password,
        :type		=> "local"
    )
    @user.grp_string	= dummy.grp_string

    #Only UID greater than 1000 are allowed for local user
    # FIXME leave this check on YaPI?
    response = true
    if @user.uid_number.to_i < 1000
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
        flash[:notice] = _("User <i>#{@user.uid}</i> was successfully created.")
        format.html { redirect_to(users_url) }
      else
        if @user.uid_number.nil?
           flash[:error] = _("Empty UID value")
        end
        if @user.uid_number.to_i < 1000
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
    @user.uid_number	= params["user"]["uid_number"]
    @user.home_directory = params["user"]["home_directory"]
    @user.cn = params["user"]["cn"]
    @user.login_shell = params["user"]["login_shell"]
    @user.user_password = params["user"]["user_password"]
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
        flash[:notice] = _("User <i>#{@user.uid}</i> was successfully updated.")
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

    ret = @user.destroy

    if ret.code_type == Net::HTTPOK
	flash[:notice] = _("User <i>#{@user.uid}</i> was successfully removed.")
    else
	flash[:error] = _("Error: Could not remove user <i>#{@user.uid}</i>.")
    end

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
end
