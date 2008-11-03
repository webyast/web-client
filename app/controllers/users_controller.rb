class UsersController < ApplicationController

  before_filter :login_required
  layout 'main'

  # GET /users
  # GET /users.xml
  def index
    @users = User.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id].rstrip)
    @user.type = ""
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new(:noHome=>nil, 
                      :error_id =>0, 
                      :defaultGroup=>nil, 
                      :newLoginName=>nil, 
                      :loginName=>nil, 
                      :groups=>nil,
                      :homeDirectory=>nil,
                      :fullName=>nil, 
                      :uid=>nil,
                      :sshkey=>nil, 
                      :newUid=>nil, 
                      :loginShell=>"/bin/bash", 
                      :error_string=>nil, 
                      :password=>nil)
    @user.id=nil
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/exportssh
  def exportssh
    @user = User.find(params[:id])
    @user.type = ""
    @user.id = @user.loginName
    logger.debug "exportssh: #{@user.inspect}"
    respond_to do |format|
      format.html # exportssh.html.erb
      format.xml  { render :xml => @user, :location => "none" }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    @user.type = ""
    @user.id = @user.loginName
  end

  # POST /users
  # POST /users.xml
  def create
    dummy = User.new(params[:user])
    @user = User.new(:noHome=>params[:nohome],
                      :error_id =>0, 
                      :defaultGroup=>dummy.defaultGroup, 
                      :newLoginName=>nil, 
                      :loginName=>dummy.loginName, 
                      :groups=>dummy.groups,
                      :homeDirectory=>dummy.homeDirectory,
                      :fullName=>dummy.fullName, 
                      :uid=>dummy.uid,
                      :sshkey=>nil, 
                      :newUid=>nil, 
                      :loginShell=>dummy.loginShell, 
                      :error_string=>nil, 
                      :password=>dummy.password)

    response = @user.post(:create, {}, @user.to_xml)
    retUser = Hash.from_xml(response.body)    
    respond_to do |format|
      if retUser["user"]["error_id"] == 0
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        @user.error_string = retUser["user"]["error_string"]
        @user.error_id = retUser["user"]["error_id"]
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    @user.id = @user.loginName
    if params["commit"] == "Export SSH-Key"
       @user.sshkey = params["user"]["sshkey"]
       response = @user.put(:sshkey, {}, @user.to_xml)
    else
       @user.defaultGroup = params["user"]["defaultGroup"]
       @user.groups = params["user"]["groups"]
       if @user.loginName != params["user"]["loginName"]
          @user.newLoginName = params["user"]["loginName"]
       end
       @user.homeDirectory = params["user"]["homeDirectory"]
       @user.fullName = params["user"]["fullName"]
       if @user.uid != params["user"]["uid"]
          @user.newUid = params["user"]["uid"]
       end
       @user.loginShell = params["user"]["loginShell"]
       @user.password = params["user"]["password"]

       response = @user.put(:update, {}, @user.to_xml)
    end
    retUser = Hash.from_xml(response.body)    
    respond_to do |format|
      if retUser["user"]["error_id"] == 0
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        @user.error_string = retUser["user"]["error_string"]
        @user.error_id = retUser["user"]["error_id"]
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.id = @user.loginName
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end
end
