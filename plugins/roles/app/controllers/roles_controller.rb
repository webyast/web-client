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

class RolesController < ApplicationController
  before_filter :login_required
  before_filter :load_displayed_roles, :only => [:update,:index]
  layout 'main'

  public

  # Initialize GetText and Content-Type.
  init_gettext "webyast-roles-ui"  # textdomain, options(:charset, :content_type)

  # Index handler. Loads information from backend and if success all required
  # fields is filled. In case of errors redirect to help page, main page or just
  # show flash with partial problem.
  def manage_roles
    @roles = Role.find :all
  end

  def self.users_role_id (role_id)
     "users_of_" + role_id.gsub(/ /,".") #replace space which cannot be in id - http://www.w3.org/TR/html4/types.html#type-name
  end

  def self.permission_role_id (permission_id, role_id)
    permission_id + ":permission_of:" + role_id
  end

  def index
    @roles.sort! {|r1,r2| r1.name <=> r2.name}
    YastModel::Permission.site = YaST::ServiceResource::Session.site
    YastModel::Permission.password = YaST::ServiceResource::Session.auth_token
    all_permissions = YastModel::Permission.find :all, :params => { :with_description => "1" }
    all_permissions = all_permissions.collect {|p| PrefixedPermission.new(p.id, p.description)}
    # create an [[key,value]] array of prefixed permissions, where key is the prefix
    @prefixed_permissions = PrefixedPermissions.new(all_permissions).sort
    @all_users_string = (User.find(:all,:params => {:getent => "1"}).collect {|user| user.login}).sort.join(",")
    Rails.logger.info @all_users_string
  end

  # Update time handler. Sets to backend new timezone and time.
  # If time is set to future it
  # still shows problems. Now it invalidate session for logged user.If
  # everything goes fine it redirect to index
  def update
    YastModel::Permission.site = YaST::ServiceResource::Session.site
    YastModel::Permission.password = YaST::ServiceResource::Session.auth_token
    all_permissions = YastModel::Permission.find(:all).collect {|p| p.id }
    changed_roles = []
    @roles.each do |role|
      new_permissions = all_permissions.find_all do |perm|
        params[RolesController.permission_role_id perm, role.name]
      end
      new_users = params[RolesController.users_role_id role.name].split(",")
      if new_permissions.sort != role.permissions.sort || new_users.sort != role.users.sort then
        role.permissions = new_permissions
        role.users = new_users
        role.id = role.name
        changed_roles << role
      end
    end
    changed_roles.each {|role| role.save }
    redirect_to :action => :index
  end

  def create
    flash[:warning] = _("Role name is already used or invalid. Allowed is combination of a-z, A-Z, numbers, space, dash and underscore only.") unless Role.new(:name => params[:role_name]).save
    redirect_to "/roles/"
  end

  private
  # Loads only roles, for which the permission/user assignment form is generated.
  # For the moment, that's all roles.
  def load_displayed_roles
    begin
      @roles = Role.find :all
    rescue ActiveResource::ResourceInvalid
      flash[:error] = _("Cannot find roles")
      redirect_to :action => "index"
    end
  end
end
