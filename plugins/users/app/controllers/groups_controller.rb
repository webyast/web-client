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
								#FIXME: fix validation regexp
    if params[:group] && params[:group][:members_string].split(",") #=~ /(#{member}(\.#{member})+)?/
      true
    else
      flash[:error] = _('Please enter a valid list of members')
      redirect_to :action => redirect_action
      false
    end
  end

  def load_permissions
    @permissions = Group.permissions
  end

  def load_user_names
    begin
      users = User.find :all
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = _("Cannot read users list.")
      return
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


public
  def index
    begin
      @groups = Group.find :all
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = _("Cannot read groups list.")
      return
    end
    Rails.logger.debug( "Groups: " + @groups.inspect )
    return unless @groups
    @permissions = Group.permissions
  end

  def new
    @group = Group.new
    @permissions = Group.permissions

    # add default properties
    defaults = {
      :gid => 0,
      :old_cn => "",
      :default_members => [],
      :members => [],
      :group_type => "local",
      :cn => "",
    }
    @group.load(defaults)
    @group.members_string = @group.members.join(",")
    @group.default_members_string = @group.default_members.join(",")
    @adding = true
    @user_names = load_user_names
    render :edit
  end

  def edit
    @permissions = Group.permissions
    validate_group_id or return
    @group = load_group or return
    @adding = false
    @user_names = load_user_names
    @group.members_string = @group.members.join(",")
    @group.default_members_string = @group.default_members.join(",")
  end

  def create
    validate_group_params( :new ) or return
    validate_group_name( :new ) or return

    @group = Group.new
    group = params[:group]

    @group.cn = group[:cn]
    @group.old_cn = group[:cn]
    @group.gid = 0              # just a placeholder, new gid will be alocated by yast call
    @group.default_members = [] # default members cannot be set
    @group.members = group[:members_string].split(",")
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

        flash[:error] = _("Cannot create group '#{@group.cn}'")
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
    @group.gid = group[:gid]
    @group.members = group[:members_string].split(",")

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

        flash[:error] = _("Cannot update group '#{ERB::Util.html_escape @group.old_cn}'}")
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
      flash[:error] = _("Cannot remove group '#{@group.cn}'")
    end

    redirect_to :action => :index and return
  end
end
