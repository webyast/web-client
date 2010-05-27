class RolesController < ApplicationController
  before_filter :login_required
  before_filter :load_role, :only => [:update,:edit]
  layout 'main'

  public

  # Initialize GetText and Content-Type.
  init_gettext "webyast-roles-ui"  # textdomain, options(:charset, :content_type)

  # Index handler. Loads information from backend and if success all required
  # fields is filled. In case of errors redirect to help page, main page or just
  # show flash with partial problem.
  def index
		@roles = Role.find :all
  end

  # Update time handler. Sets to backend new timezone and time.
  # If time is set to future it
  # still shows problems. Now it invalidate session for logged user.If
  # everything goes fine it redirect to index
  def update
    @role.id = params[:id]
		new_perm = (params[:assigned_perms]||"").tr("_",".").split(',')
		if @role.permissions.sort != new_perm.sort
			@role.permissions = new_perm
		end
    @role.users = params[:assigned_users].split(',')
		@role.save
		redirect_to :action => :edit, :id => params[:id]
  end

	def edit
		#permissions controller is not YastModel
    YastModel::Permission.site = YaST::ServiceResource::Session.site
    YastModel::Permission.password = YaST::ServiceResource::Session.auth_token
		@permissions = YastModel::Permission.find :all, :params => { :with_description => "1" }
		logger.info "permissions #{@permissions.inspect}"
    @users = User.find :all
  end

	def create
		#TODO check name
		Role.new(:name => params[:role_name]).save
		redirect_to "/roles/"
	end

  private
  def load_role
    begin
  		@role = Role.find params[:id]
    rescue ActiveResource::ResourceInvalid
      flash[:error] = _("Invalid role name")
      redirect_to :action => "index"
    end
  end

end
