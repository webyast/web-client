class UsersController < ApplicationController

  before_filter :login_required
  layout 'main'


  # GET /users
  # GET /users.xml
  def index
    set_permissions(controller_name)
    @users = User.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    set_permissions(controller_name)
    @user = User.new(:no_home=>nil, 
                      :error_id =>0, 
                      :default_group=>nil, 
                      :new_login_name=>nil, 
                      :login_name=>nil, 
                      :groups=>nil,
                      :home_directory=>nil,
                      :full_name=>nil, 
                      :uid=>nil,
                      :sshkey=>nil, 
                      :new_uid=>nil, 
                      :login_shell=>"/bin/bash", 
                      :error_string=>nil, 
                      :password=>nil,
                      :type=>"local")
    @user.id=nil
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/exportssh
  def exportssh
    set_permissions(controller_name)
    @user = User.find(params[:id])
    @user.type = ""
    @user.id = @user.login_name
    logger.debug "exportssh: #{@user.inspect}"
    respond_to do |format|
      format.html # exportssh.html.erb
      format.xml  { render :xml => @user, :location => "none" }
    end
  end

  # GET /users/1/edit
  def edit
    set_permissions(controller_name)
    @user = User.find(params[:id])
    @user.type = ""
    @user.id = @user.login_name
  end

  # POST /users
  # POST /users.xml
  def create
    dummy = User.new(params[:user])
    @user = User.new(:no_home=>params[:nohome],
                      :error_id =>0, 
                      :default_group=>dummy.default_group, 
                      :new_login_name=>nil, 
                      :login_name=>dummy.login_name, 
                      :groups=>dummy.groups,
                      :home_directory=>dummy.home_directory,
                      :full_name=>dummy.full_name, 
                      :uid=>dummy.uid,
                      :sshkey=>nil, 
                      :new_uid=>nil, 
                      :login_shell=>dummy.login_shell, 
                      :error_string=>nil, 
                      :password=>dummy.password,
                      :type=>"local")

    retUser = {}
    #Only UID greater than 1000 are allowed for local user
    if @user.uid.to_i < 1000    
       retUser["user"] = {}
       retUser["user"]["error_string"] = "UID: value >= 1000 is valid for local user only"
       retUser["user"]["error_id"] = 2
    else
       response = @user.post(:create, {}, @user.to_xml)
       retUser = Hash.from_xml(response.body)    
    end
    respond_to do |format|
      if retUser["user"]["error_id"] == 0
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(users_url) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        @user.error_string = retUser["user"]["error_string"]
        @user.error_id = retUser["user"]["error_id"]
        flash[:error] = @user.error_string
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    @user.new_login_name = nil
    @user.new_uid = nil
    @user.id = @user.login_name
    if params["commit"] == "Export SSH-Key"
       @user.sshkey = params["user"]["sshkey"]
       response = @user.put(:sshkey, {}, @user.to_xml)
    else
       @user.default_group = params["user"]["default_group"]
       @user.groups = params["user"]["groups"]
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
       response = @user.put(:update, {}, @user.to_xml)
    end
    retUser = Hash.from_xml(response.body)    
    respond_to do |format|
      if retUser["user"]["error_id"] == 0
        if params["commit"] == "Export SSH-Key"
           flash[:notice] = 'SSH-Key was successfully exported.'
        else
           flash[:notice] = 'User was successfully updated.'
        end
        format.html { redirect_to(users_url) }
        format.xml  { head :ok }
      else
        @user.error_string = retUser["user"]["error_string"]
        @user.error_id = retUser["user"]["error_id"]
        flash[:error] = @user.error_string
        if params["commit"] == "Export SSH-Key"
           format.html { render :action => "exportssh" }
        else
           format.html { render :action => "edit" }
        end
	format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.id = @user.login_name
    @user.type = "local"
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
end
