include ApplicationHelper

class CommandsController < ApplicationController

  before_filter :login_required
  layout 'main'

  public

  def index
    id = params[:service_id]
    logger.debug "services/show #{id}"
    @service = Service.find(id)
    @commands = []
    @commands = @service.commands.split(",") unless @service==nil
    if params[:last_error] && params[:last_error] != 0
       @service.error_id = params[:last_error]
       if params[:last_error_string]
          @service.error_string = params[:last_error_string]
       end
    end
    render
  end

  def update
    @service = Service.find(params[:service_id])
    @service.id = @service.link
    commandId = "commands/"
    commandId << params[:id]
    logger.debug "calling #{commandId} with service #{@service.inspect}"
    response = @service.put(commandId)
    retService = Hash.from_xml(response.body)
    logger.debug "returns #{retService["service"].inspect}"  
    if retService["service"]["error_id"] != 0
       redirect_to :back, :action => "show" , :last_error_string =>retService["service"]["error_string"], :last_error =>retService["service"]["error_id"]
    else
       redirect_to :back, :action => "show"
    end
  end

end
