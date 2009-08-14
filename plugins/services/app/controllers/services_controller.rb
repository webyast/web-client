require 'service'

class ServicesController < ApplicationController
  before_filter :login_required
  layout 'main'

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_services"  # textdomain, options(:charset, :content_type)

  def index
    proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.services')
    @permissions = proxy.permissions

    @services = Service.find(:all, :from => '/services.xml')
    @table = []
    counter = 1
    max_column = 0
    table_counter = 1
    @services.each do | s |
      @services[counter-1].command_list = []
      commands = %w{status start stop restart force-reload bogus} # FIXME s.commands is gone
      commands.each do | comm |
        cname = comm # FIXME comm.name is gone
        iname = cname
        case iname
        when "run"
          iname = "start"
        when "try-restart"
          iname = "restart"
        when "force-reload"
          iname = "reload"
        else
          iname = "empty"
        end
        c = {:name => cname, :icon => "/images/#{iname}.png" }
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

    if params[:fancy] == "1"
      render :fancy_index and return
    end
  end

  def execute
    @service = Service.find(params[:service_id])
    @service.id = @service.link
    command_id = "commands/" + params[:id]
    logger.debug "calling #{command_id} with service #{@service.inspect}"
    response = @service.put(command_id)

    # we get a hash with exit, stderr, stdout
    ret = Hash.from_xml(response.body)
    ret = ret["hash"]
    logger.debug "returns #{ret.inspect}"
    
    @result_string = ""
    @result_string << ret["stdout"] if ret["stdout"]
    @result_string << ret["stderr"] if ret["stderr"]
    @error_string = ret["exit"].to_s # TODO translate exit codes (use YaST?)
    if ret["exit"] == 0
       @error_string = _("success")
    end
    render(:partial =>'result')
  end

end
