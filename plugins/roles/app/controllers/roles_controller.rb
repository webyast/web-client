class RolesController < ApplicationController
  before_filter :login_required
  layout 'main'

  public

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_roles"  # textdomain, options(:charset, :content_type)

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
  end

	def edit
		#permissions controller is not YastModel
    YastModel::Permission.site = YaST::ServiceResource::Session.site
    YastModel::Permission.password = YaST::ServiceResource::Session.auth_token
		permissions = YastModel::Permission.find :all
		@permissions = permissions.collect do |p| p.id end
		@permissions.sort
		logger.info "permissions #{@permissions.inspect}"
	end

	def create
		#TODO check name
		Role.new(:name => params[:role_name]).save
		redirect_to "/roles/"
	end

end
