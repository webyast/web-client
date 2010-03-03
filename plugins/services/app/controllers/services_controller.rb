require 'yast/service_resource'

class ServicesController < ApplicationController
  before_filter :login_required
  layout 'main'

  private

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_services"  # textdomain, options(:charset, :content_type)

  public

  def initialize
  end

  def show_status

    begin
	@response = Service.find(:one, :from => params[:id].intern, :params => { "custom" => params[:custom]})
    rescue ActiveResource::ResourceNotFound => e
	Rails.logger.error "Resource not found: #{e.to_s}: #{e.response.body}"
	render :text => _('(cannot read status)') and return
    end

    render(:partial =>'status', :object => @response.status, :params => params)
  end

  # GET /services
  # GET /services.xml
  def index

    @permissions = Service.permissions
    @services = []
    begin
      @services	= Service.find(:all, :params => { :read_status => 1 })
    rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
    end
  end

  # PUT /services/1.xml
  def execute
    args	= { :execute => params[:id], :custom => params[:custom] }
    response = Service.put(params[:service_id], args)
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
