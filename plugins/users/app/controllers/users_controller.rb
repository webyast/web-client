#--
# Copyright (c) 2009-2010 Novell, Inc.
# 
# All Rights Reserved.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
# 
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#++

require 'yast/service_resource'

class UsersController < ApplicationController

  before_filter :login_required
  layout 'main'

  private
  def client_permissions
    @permissions = User.permissions
    @permissions.merge!(Group.permissions)
#    if defined?(Role) == 'constant' && Role.class == Class
#      @permissions.merge!(Role.permissions)
#    end
  end

  # Initialize GetText and Content-Type.
  init_gettext "webyast-users-ui"

  def load_users
    begin
      User.find :all
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = _("No users found.")
      []
    end
  end

  # Try to find Roles
  # when no succeed, just return empty list
  # because Roles are no strictly required
  # see bnc#628223
  def load_roles
    roles=[]
    begin
     roles = Role.find :all
    rescue Exception => e
     match = /^Interface ([[:alpha:].]*) missing/.match e.to_s
     if match || e.class==NameError
      puts "Couldn't inititalize Role object with error: ", e
     else
      raise
     end
    end
    return roles
  end

def all_users
    all_users_list = []
    all_users = User.find :all
    all_users.each do |user|
      all_users_list.push(user.uid)
    end
    all_users_list.join(",")
end
  public
  def initialize
  end

  def save_roles (userid,roles_string)
   #FIXME: not very unique permission names
#   if @permissions[:modify]==true && @permissions[:assign]==true

    all_roles = load_roles
     roles = roles_string.split(",")
     my_roles=[]
     all_roles.each do |role|
      role.id=role.name
      if role.users.include?(userid)
       if roles.include?(role.name)
        # already written - do nothing
        roles.delete(role.name)
       else
        # remove item
        role.users.delete(userid)
        role.save
        roles.delete(role.name)
       end
      end
     end
     roles.each do |role|
      # this should be added
      r = Role.find(role)
      r.id=r.name
      r.users << userid
      r.save
    end
  end

  # GET /users
  # GET /users.xml
  def index
    return unless client_permissions
    @users = []
    begin
      @users = load_users
      @users.each do |user|
        user.user_password2 = user.user_password
        user.uid_number	= user.uid_number
        user.grp_string = user.grouplist.collect{|g| g.cn}.join(",")
        my_roles=[]
        all_roles=[]

#FIXME: description
	@roles=load_roles
        @roles.each do |role|
         if role.users.include?(user.id)
          my_roles.push(role.name)
         end
         all_roles.push(role.name)
        end

        user.roles_string = my_roles.join(",")
        @all_roles_string = all_roles.join(",")
	@groups = []
        if @permissions[:groupsget] == true
          @groups = Group.find :all
        end
	grps_list=[]
        @groups.each do |group|
	 grps_list.push(group.cn)
        end
        @all_grps_string = grps_list.join(",")
      end
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    return unless client_permissions
    @user = User.new( :id => :nil,
      :groupname	=> nil,
      :cn		=> nil,
      :grouplist	=> [],
      :allgroups	=> [],
      :home_directory	=> nil,
      :cn		=> nil,
      :uid		=> nil,
      :uid_number	=> nil,
      :login_shell	=> "/bin/bash",
      :user_password	=> nil,
      :user_password2	=> nil,
      :type		=> "local",
      :roles_string	=> ""
    )
        @all_roles_string = ""
        all_roles=[]
         @roles = load_roles
         my_roles=[]
         @roles.each do |role|
          all_roles.push(role.name)
         end
        @all_roles_string = all_roles.join(",")

    @all_users_string = all_users

    @groups = []
    if @permissions[:groupsget] == true
      @groups = Group.find :all
    end
    grp_list=[]
    @groups.each do |group|
     grp_list.push(group.cn)
    end
    @all_grps_string = grp_list.join(",")
    
    @user.grp_string = ""
  end


  # GET /users/1/edit
  def edit
    return unless client_permissions
    @user = User.find(params[:id])
    @groups = Group.find(:all)

    #FIXME handle if id is invalid

    @user.type	= ""
    @user.id	= @user.uid # use id for storing index value (see update)
    @user.grp_string = ""

    @all_grps_string = ""

    # FIXME hack, this must be done properly
    # (my keys in camelCase were transformed to under_scored)
    # XXX this looks like code which do nothing!!!
    @user.uid_number	= @user.uid_number
    @user.home_directory	= @user.home_directory
    @user.login_shell	= @user.login_shell
    @user.user_password	= @user.user_password
    @user.user_password2= @user.user_password

    @user.grouplist.each do |group|
       if @user.grp_string.blank?
          @user.grp_string = group.cn
       else
          @user.grp_string += ",#{group.cn}"
       end
    end
    @groups.each do |group|
       if @all_grps_string.blank?
          @all_grps_string = group.cn
       else
          @all_grps_string += ",#{group.cn}"
       end
    end
  end


  # POST /users
  # POST /users.xml
  def create
    return unless client_permissions
    dummy = User.new(params[:user])
    #do not know, why this will not be assigned in the constructor
    #(JR: because ActiveResource fills only known attributes, but whole gro_string stuff "smells" for me)
    dummy.grp_string = params[:user][:grp_string] 

    dummy.grouplist = []
    if dummy.grp_string != nil
       dummy.grp_string.split(",").each do |groupname|
	  group = { "cn" => groupname.strip }
	  dummy.grouplist.push group
       end
    end

    @user = User.new(
	:groupname	=> dummy.groupname,
        :uid		=> dummy.uid,
        :grouplist	=> dummy.grouplist,
        :home_directory	=> dummy.home_directory,
	:cn		=> dummy.cn,
        :uid_number	=> dummy.uid_number,
        :login_shell	=> dummy.login_shell,
        :user_password	=> dummy.user_password,
        :user_password2	=> dummy.user_password,
	:roles_string 	=> dummy.roles_string,
        :type		=> "local"
    )
    @user.grp_string	= dummy.grp_string
    @all_users_string = all_users

    response = true
    begin
        response = @user.save
	if dummy.roles_string!=nil
         save_roles(@user.id,dummy.roles_string)
        end
        rescue ActiveResource::ClientError => e
          flash[:error] = YaST::ServiceResource.error(e)
          response = false
    end
    if response
      flash[:notice] = _("User <i>%s</i> was successfully created.") % @user.uid
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end

  # PUT /users/1.xml
  def update
    return unless client_permissions

    # :id was not changed, so it can be used for find even after renaming
    @user = User.find(params[:user][:id])
    
    #@user.id = @user.uid
    @user.uid	= params["user"]["uid"] # 'uid' may have been changed
    @user.groupname = params["user"]["groupname"]

    @user.grouplist = []
    if params["user"]["grp_string"] != nil
       params["user"]["grp_string"].split(",").each do |groupname|
	  group = { "cn" => groupname.strip }
	  @user.grouplist.push group
       end
    end

    @user.uid_number	= params["user"]["uid_number"]
    @user.home_directory = params["user"]["home_directory"]
    @user.cn = params["user"]["cn"]
    @user.login_shell = params["user"]["login_shell"]
    @user.user_password = params["user"]["user_password"]
    @user.type = "local"
    if params["user"]["roles_string"]!=nil
     save_roles(@user.id,params["user"]["roles_string"])
    end

    begin
      if @user.save
	flash[:notice] = _("User <i>%s</i> was successfully updated.") % @user.uid
	redirect_to :action => "index"
      end
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      redirect_to :action => "index"
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    return unless client_permissions
    @user = User.find(params[:id])
    @user.id = @user.uid
    @user.type = "local"

    ret = @user.destroy

    if ret.code_type == Net::HTTPOK
      flash[:notice] = _("User <i>%s</i> was successfully removed.") % @user.uid
    else
      flash[:error] = _("Error: Could not remove user <i>%s</i>.") % @user.uid
    end

    redirect_to :action => "index"
  end
end
