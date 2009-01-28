require 'service'

class ServicesController < ApplicationController
  before_filter :login_required
  layout 'main'

  def index
    setPermissions(controller_name)

    @services = Service.find(:all, :from => '/services.xml')
    @table = []
    counter = 1
    maxColumn = 0
    tableCounter = 1
    @services.each do | s |
       @services[counter-1].commandList = []
       s.commands.split(",").each do | comm |
          case comm
            when "start", "run"
               c = {:name=>comm, :icon=>"/images/start.png" }
            when "stop"
               c = {:name=>comm, :icon=>"/images/stop.png" }
            when "restart", "try-restart"
               c = {:name=>comm, :icon=>"/images/restart.png" }
            when "reload", "force-reload"
               c = {:name=>comm, :icon=>"/images/reload.png" }
            when "status"
               c = {:name=>comm, :icon=>"/images/status.png" }
            when "probe"
               c = {:name=>comm, :icon=>"/images/probe.png" }
            else
               c = {:name=>comm, :icon=>"/images/empty.png" }
          end
          @services[counter-1].commandList << c
       end
       if s.link == "ntp"
          #add configuration module if there is a read permission
          c = {:name=>"configure", :icon=>"/images/configure.png" }
          @services[counter-1].commandList << c
       end
       if @services[counter-1].commandList.size > maxColumn
          maxColumn = @services[counter-1].commandList.size
       end
       if tableCounter * 4 == counter #next table have to begin
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
    @resultString = retService["service"]["error_string"]
    @errorString = "failed"
    if retService["service"]["error_id"]==0 
       @errorString = "success"
    end
    render (:partial =>'result')
  end

end
