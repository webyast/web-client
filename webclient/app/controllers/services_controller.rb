require 'service'

class ServicesController < ApplicationController
  before_filter :login_required
  layout 'main'

  def index
    set_permissions(controller_name)

    @services = Service.find(:all, :from => '/services.xml')
    @table = []
    counter = 1
    max_column = 0
    table_counter = 1
    @services.each do | s |
       @services[counter-1].command_list = []
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
          @services[counter-1].command_list << c
       end
       if s.link == "ntp"
          #add configuration module if there is a read permission
          c = {:name=>"configure", :icon=>"/images/configure.png" }
          @services[counter-1].command_list << c
       end
       if @services[counter-1].command_list.size > max_column
          max_column = @services[counter-1].command_list.size
       end
       if table_counter * 4 == counter #next table have to begin
          @table << max_column
          table_counter +=1
          max_column = 0
       end
       counter += 1
    end
    if max_column > 0
       @table << max_column #add last table
    end
    if params[:last_error] && params[:last_error] != 0
       @last_result = params[:last_error]
    else
       @last_result = 0
    end
    if params[:last_error_string]
       @last_result_string = params[:last_error_string]
    else
       @last_result_string = ""
    end
  end

  def execute
    @service = Service.find(params[:service_id])
    @service.id = @service.link
    command_id = "commands/"
    command_id << params[:id]
    logger.debug "calling #{command_id} with service #{@service.inspect}"
    response = @service.put(command_id)
    ret_service = Hash.from_xml(response.body)
    logger.debug "returns #{ret_service["service"].inspect}"
    @result_string = ret_service["service"]["error_string"]
    @error_string = "failed"
    if ret_service["service"]["error_id"]=="0"
       @error_string = "success"
    end
    render (:partial =>'result')
  end

end
