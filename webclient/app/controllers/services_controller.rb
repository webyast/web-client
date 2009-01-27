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
    @lastResult = retService["service"]["error_id"]
    @lastResultString = retService["service"]["error_string"]
    errorstring = "failed"
    if @lastResult==0 
       errorstring = "success"
    end

    render :text=>"
   <div class=\"box\">
   <div class=\"table\">
      <img src=\"images/bg-th-left.gif\" width=\"8\" height=\"7\" alt=\"\" class=\"left\" />
      <img src=\"images/bg-th-right.gif\" width=\"7\" height=\"7\" alt=\"\" class=\"right\" />
      <table class=\"listing form\" cellpadding=\"0\" cellspacing=\"0\">
      <tr>
          <th class=\"full\" colspan=\"2\">Service Call Result</th>
      </tr>
      <tr>
          <td class=\"first\" width=\"120\"><strong>Result</strong></td>
          <td class=\"last\">#{errorstring}</td>
      </tr>
      <tr class=\"bg\">
          <td class=\"first\"><strong>Description</strong></td>
          <td class=\"last\">#{@lastResultString}</td>
      </tr>
      </table>
      <p><a href=\"services\" class=\"button\">Back</a></p>
   </div>
   </div>"
  end

end
