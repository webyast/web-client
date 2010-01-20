require 'yast/service_resource'

class ServicesController < ApplicationController
  before_filter :login_required
  layout 'main'

  private
  def client_permissions
    @client = YaST::ServiceResource.proxy_for('org.opensuse.yast.modules.yapi.services')
    unless @client
      flash[:notice] = _("Invalid session, please login again.")
      redirect_to( logout_path ) and return
    end
    @permissions = @client.permissions rescue {}
  end

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_services"  # textdomain, options(:charset, :content_type)

  public

  def initialize
  end

  def show_status
    return unless client_permissions

    begin
	args	= {}
	args[:custom]	= 1 if params.has_key? "custom"
	@response = @client.find(:one, :from => params[:id].intern, :params => args)
    rescue ActiveResource::ResourceNotFound => e
	Rails.logger.error "Resource not found: #{e.to_s}: #{e.response.body}"
	render :text => _('(cannot read status)') and return
    end

    render(:partial =>'status', :object => @response.status, :params => params)
  end

  # GET /services
  # GET /services.xml
  def index
    return unless client_permissions

    @services = []
    begin
      @services	= @client.find(:all, :params => params)
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
    end

    # sort services by name (case insensitive)
    @services.sort! {|s1,s2| s1.name.downcase <=> s2.name.downcase } unless @services.nil?

    @custom_services	= []
    begin
      args		= {}
      args[:custom]	= 1
      @custom_services	= @client.find(:all, :params => args)
    end

    @custom_services.sort! {|s1,s2| s1.name.downcase <=> s2.name.downcase } unless @custom_services.nil?
  end

  def execute

    return unless client_permissions

    # PUT /services/1.xml
    args	= { :execute => params[:id] }
    args[:custom]	= 1 if params.has_key? "custom"
    response = @client.put(params[:service_id], args)

    # we get a hash with exit, stderr, stdout
    ret = Hash.from_xml(response.body)
    ret = ret["hash"]
    logger.debug "returns #{ret.inspect}"
    
    @result_string = ""
    @result_string << ret["stdout"] if ret["stdout"]
    @result_string << ret["stderr"] if ret["stderr"]
    @error_string = ret["exit"].to_s
    if ret["exit"] == 0 || ret["exit"] == "0"
       @error_string = _("success")
    end
    render(:partial =>'result', :params => params)
  end


end
