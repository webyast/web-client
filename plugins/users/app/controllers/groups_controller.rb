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

class GroupsController < ApplicationController

  before_filter :login_required
  before_filter :load_permissions, :only => [:index,:add,:edit]
  layout 'main'

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_users"

private
  def validate_group_id
    if params[:id].blank?
      flash[:error] = _('Missing group name parameter')
      redirect_to :action => :index
      false
    else
      true
    end
  end

  def validate_group_params( redirect_action )
    if params[:group] && (! params[:group].empty?)
      true
    else
      flash[:error] = _('Missing group parameters')
      redirect_to :action => redirect_action
      false
    end
  end

  def validate_group_name( redirect_action )
    if params[:group] && params[:group][:cn] =~ /[a-z]+/
      true
    else
      flash[:error] = _('Please enter a valid group name')
      redirect_to :action => redirect_action
      false
    end
  end

  def validate_group_gid( redirect_action )
    if params[:group] && params[:group][:gid] =~ /\d+/
      true
    else
      flash[:error] = _('Please enter a valid GID')
      redirect_to :action => redirect_action
      false
    end
  end

  def validate_group_type( redirect_action )
    if params[:group] && ["system","local"].include?( params[:group][:group_type] )
      true
    else
      flash[:error] = _('Please enter a valid group type. Only "system" or "local" are allowed.')
      redirect_to :action => redirect_action
      false
    end
  end

  def validate_members( redirect_action )
    member = "[a-z]+"
    if params[:group] && params[:group][:members_string] =~ /(#{member}( *, *#{member})+)?/
      true
    else
      flash[:error] = _('Please enter a valid list of members')
      redirect_to :action => redirect_action
      false
    end
  end

  def load_permissions
    @permissions = Group.permissions
    @permissions.merge!(User.permissions)
  end

  def load_user_names
    users = []
    if @permissions[:usersget] == true
    begin
      users = User.find :all
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = _("Cannot read users list.")
      return
    end
    end
    users.collect {|u| u.cn }
  end

  def load_group
    begin
      Group.find params[:id]
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = _("Group named '#{params[:id]}' was not found.")
      redirect_to :action => :index
      nil
    end
  end

  def load_groups
    begin
      Group.find :all
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = _("No groups found.")
      []
    end
  end

public
  def index
    begin
      return unless load_permissions
      @groups = load_groups
      @groups.sort! { |a,b| a.cn <=> b.cn }
      @groups.each do |group|
       group.members_string = group.members.join(",")
      end
    @all_users_string = ""
    @users = []
    if @permissions[:usersget] == true
      @users = User.find(:all, :params => { :attributes => "uid"})
    end
        @users.each do |user|
       if @all_users_string.blank?
          @all_users_string = user.uid
       else
          @all_users_string += ",#{user.uid}"
       end
    end

    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = _("Cannot read groups list.")
      return
    end
    Rails.logger.debug( "Groups: " + @groups.inspect )
    return unless @groups
  end

  def new
    @group = Group.new
    @permissions = Group.permissions

    # add default properties
    defaults = {
      :gid => 0,
      :old_cn => "",
      :members => [],
      :group_type => "local",
      :cn => "",
    }
    @group.load(defaults)
    @group.members_string = @group.members.join(",")
    @adding = true
    @user_names = load_user_names
    @all_users_string = ""
    @users = []
    if @permissions[:usersget] == true
      @users = User.find(:all)
    end
        @users.each do |user|
       if @all_users_string.blank?
          @all_users_string = user.uid
       else
          @all_users_string += ",#{user.uid}"
       end
    end
    render :new
  end

  def edit
    @permissions = Group.permissions
    validate_group_id or return
    @group = load_group or return
    @adding = false
    @user_names = load_user_names
    @group.members_string = @group.members.join(",")

    @users = User.find(:all)
    @all_users_string = ""
        @users.each do |user|
       if @all_users_string.blank?
          @all_users_string = user.uid
       else
          @all_users_string += ",#{user.uid}"
       end
    end
  end

  def create
    validate_group_params( :new ) or return
    validate_group_name( :new ) or return

    @group = Group.new
    group = params[:group]

    @group.cn = group[:cn]
    @group.old_cn = group[:cn]
    @group.members = group[:members_string].split(",").collect {|cn| cn.strip}
    validate_members( :new ) or return
    @group.group_type = group[:group_type]
    validate_group_type( :new ) or return

    begin
      if @group.save
        flash[:message] = _("Group '#{@group.cn}' has been added.")
      end
    rescue ActiveResource::ServerError, ActiveResource::ResourceNotFound => ex
      begin
        Rails.logger.error "Received error: #{ex.inspect}"
        err = Hash.from_xml ex.response.body

        if !err['error']['message'].blank?
          Rails.logger.error "Cannot create group '#{@group.cn}': #{ERB::Util.html_escape err['error']['message']}"
        end

        flash[:error] = _("Cannot create group '#{@group.cn}' : #{ERB::Util.html_escape err['error']['message']}")
      rescue Exception => e
        Rails.logger.error "Exception: #{e}"
        # XML parsing has failed, display complete response
        flash[:error] = _("Unknown backend error")
        Rails.logger.error "Unknown backend error: #{ex.response.body}"
      end
      redirect_to :action => :new and return
    end

    redirect_to :action => :index and return
  end


  def update
    params[:id]=params[:group][:old_cn]
    validate_group_id or return
    validate_group_params( :index ) or return
    validate_group_name( :index ) or return
    validate_members( :index ) or return
    @group = load_group or return

    group = params[:group]
    @group.cn = group[:cn]
    @group.gid = group[:gid].to_i
    @group.members = group[:members_string].split(",").collect {|cn| cn.strip}
    @permissions = Group.permissions
    @group.id = @group.old_cn # set id, so ActiveResource can use it for saving

    begin
      if @group.save
        flash[:message] = _("Group '#{@group.cn}' has been updated.")
      else
        if @group.errors.size > 0
          Rails.logger.error "Group save failed: #{@repo.errors.errors.inspect}"
          flash[:error] = generate_error_messages @repo, attribute_mapping
        else
          flash[:error] = _("Cannot update group '#{group.old_cn}': Unknown error")
        end

        render :edit and return
      end
    rescue ActiveResource::ServerError, ActiveResource::ResourceNotFound => ex
      begin
        Rails.logger.error "Received ActiveResource::ServerError: #{ex.inspect}"
        err = Hash.from_xml ex.response.body

        if !err['error']['message'].blank?
          Rails.logger.error "Cannot update group '#{@group.old_cn}': #{err['error']['message']}"
        end

        flash[:error] = _("Cannot update group '#{ERB::Util.html_escape @group.old_cn}' : #{ERB::Util.html_escape err['error']['message']}")
      rescue Exception => e
          # XML parsing has failed, display complete response
          flash[:error] = _("Unknown backend error: #{ERB::Util.html_escape ex.response.body}")
          Rails.logger.error "Unknown backend error: #{ex.response.body}"
      end

      render :edit and return
    end

    redirect_to :action => :index and return
  end

  def destroy
    validate_group_id or return
    @group = load_group or return
    @group.id = @group.cn

    begin
      if @group.destroy
        flash[:message] = _("Group '#{@group.cn}' has been deleted.")
      end
    rescue ActiveResource::ResourceNotFound => e
      err = Hash.from_xml e.response.body
      flash[:error] = _("Cannot remove group '#{@group.cn}' : #{ERB::Util.html_escape err['error']['message']}")
    end

    redirect_to :action => :index and return
  end
end
