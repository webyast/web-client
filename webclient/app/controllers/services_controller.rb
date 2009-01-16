require 'service'

class ServicesController < ApplicationController
  before_filter :login_required
  layout 'main'

  def index
    @services = Service.find(:all, :from => '/services.xml')
    @table = []
    counter = 1
    maxColumn = 0
    tableCounter = 1
    @services.each do | s |
       @services[counter-1].commandList = s.commands.split(",")
       if @services[counter-1].commandList.size > maxColumn
          maxColumn = @services[counter-1].commandList.size
       end
       if tableCounter.to_int.lcm(6) == counter #next table have to begin
          @table << maxColumn
          tableCounter +=1
          maxColumn = 0
       end
       counter += 1
    end
    if maxColumn > 0
       @table << maxColumn #add last table
    end
    if params[:last_error] && params[:last_error] != 0
       @lastResult = params[:last_error]
    else
       @lastResult = 0
    end
    if params[:last_error_string]
       @lastResultString = params[:last_error_string]
    else
       @lastResultString = ""
    end
  end

  def execute
    @service = Service.find(params[:service_id])
    @service.id = @service.link
    commandId = "commands/"
    commandId << params[:id]
    logger.debug "calling #{commandId} with service #{@service.inspect}"
    response = @service.put(commandId)
    retService = Hash.from_xml(response.body)
    logger.debug "returns #{retService["service"].inspect}"  
    redirect_to :action=> :index , :last_error_string =>retService["service"]["error_string"], :last_error =>retService["service"]["error_id"]
  end

end
