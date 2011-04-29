#--
# Copyright (c) 2009-2010 Novell, Inc.
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#++

require 'yast/service_resource'
require 'client_exception'
require 'open-uri' # RORSCAN_ITL

class StatusController < ApplicationController

  before_filter :login_required
  layout "main"

  DEFAULT_LINES = 50

  private
  def client_permissions
    @permissions = Logs.permissions #each model return same permissions as it share policy
  end

  #
  # evaluate error string if a limit for a group (CPU,Memory,Disk,...) has been reached
  #
  # returns e.g. "Disk/user; Disk/root"
  #
  def limits_reached (group)
    status = ""
    group.single_graphs.each do |single_graph|
      single_graph.lines.each do |line|
        if line.limits.reached == "true"
          label = group.id
          label += "/" + single_graph.headline if group.single_graphs.size > 1
          label += "/" + line.label unless line.label.blank?
          if status.empty?
            status = label
          else
            status += "; " + label
          end
        end
      end
    end
    return status
  end

  #
  # retrieving the data from collectd for a single value like waerden+memory+memory-used
  # return an array of [[timestamp1,value1], [timestamp2,value2],...]
  #
  def get_data(id, column_id, from, till, scale = 1)
    @limits_list = Hash.new
    @limits_list[:reached] = String.new
    @data_group = Hash.new

    stat_params = { :start => from.to_i.to_s, :stop => till.to_i.to_s }
    status = Metrics.find(id, :params => stat_params )
    ret = Array.new
    if status.attributes["value"].is_a? Array
      status.attributes["value"].each{ |value|
        if value.column == column_id
          value.value.collect!{|x| x.tr('\"','')} #removing \"
          value.value.size.times{|t| ret << [(value.start.to_i + t*value.interval.to_i)*1000, value.value[t].to_f/scale]} # *1000 --> jlpot evalutas MSec for date format  # RORSCAN_ITL
          break
        end
      }
    else #only one value
      status.value.value.collect!{|x| x.tr('\"','')} #removing \"
      status.value.value.size.times{|t| ret << [(status.value.start.to_i + t*status.value.interval.to_i)*1000, status.value.value[t].to_f/scale]} # *1000 --> jlpot evalutas MSec for date format # RORSCAN_ITL
    end

    #strip zero values at the end of the array
    while ret.last && ret.last[1] == 0
      ret.pop
    end

    ret
  end


 # Initialize GetText and Content-Type.
  init_gettext "webyast-status-ui"

  public

  def initialize
  end

  def confirm_status
    if not params.has_key?(:url)
      raise "Missing service URL for POST request"
    end
    base_path = params[:url][0..params[:url].rindex("/")-1]
    base_name = params[:url][params[:url].rindex("/")+1..(params[:url].size-1) ]
    res_resource = OpenStruct.new(:href => base_path, :singular? => true)
    proxy = YaST::ServiceResource.class_for_resource(res_resource)
    proxy.post(base_name)
    redirect_to :controller => :controlpanel, :action => :index
  end

  def ajax_log_custom
    # set the site to the view so it can load the log
    # dynamically
    if not params.has_key?(:id)
      raise "Unknown log file"
    end
    lines = params[:lines].to_i || DEFAULT_LINES
    pos_begin = params[:pos_begin].to_i || 0
    begin
      log = Logs.find(params[:id], :params => { :pos_begin => pos_begin, :lines => lines })
      content = log.content.value if log
      position = log.content.position.to_i if log
      render(:partial => 'status_log',
             :locals => { :content => content, :position => position, :lines => lines, :id => params[:id] }) and return
    rescue ActiveResource::ServerError => error
	error_hash = Hash.from_xml error.response.body
	logger.warn error_hash.inspect
	if error_hash["error"] && error_hash["error"]["type"] == "NO_PERM"
           render :text => error_hash["error"]["description"] and return
	else
           raise error
	end
    end
  end

  def index
    client_permissions
    @logs = Logs.find(:all)
    @plugins = Plugins.find(:all)
    begin
      @graphs = Graphs.find(:all, :params => { :checklimits => true })
      #sorting graphs via id
      @graphs.sort! {|x,y| y.id <=> x.id }
      flash[:notice] = _("No data found for showing system status.") if @graphs.blank? # RORSCAN_ITL
      rescue ActiveResource::ServerError => error
	error_hash = Hash.from_xml error.response.body
	logger.warn error_hash.inspect
	if error_hash["error"] &&
          (error_hash["error"]["type"] == "SERVICE_NOT_RUNNING" ||
           error_hash["error"]["type"] == "COLLECTD_SYNC_ERROR")
           if error_hash["error"]["type"] == "SERVICE_NOT_RUNNING"
             flash[:error] = _("Status not available.")
           else
             flash[:error] = error_hash["error"]["description"]
           end
	else
           raise error
	end
      ensure
        @graphs ||= []
    end
  end

  #
  # AJAX call for showing status overview
  #
  def show_summary
    begin
      client_permissions
    rescue Errno::ECONNREFUSED => e #connection to service has been lost, but still trying
      status = _("Can't connect to host")
      host = Host.find(session[:host]) rescue nil
      status = _("Can't connect to host %s.") % host.name if host #this string is already translated int webclient
      render(:partial => "status_summary",
             :locals => { :status => status, :level => 'error', :error => nil,
                          :refresh_timeout =>  refresh_timeout })
      return
    rescue ActiveResource::UnauthorizedAccess => error
      # handle unauthorized error - the session timed out
      Rails.logger.error "Error: ActiveResource::UnauthorizedAccess"
      render :partial => "status_summary", :locals => { :status => '', :level => 'error', :error => error, :refresh_timeout => nil }
      return
    end

    level = "ok"
    status = ""
    ret_error = nil
    refresh = true
    ActionController::Base.benchmark("Graphs data read from the server") do
      begin
        graphs = Graphs.find(:all, :params => { :checklimits => true, :background => true }) || []

        # is it a background progress?
        if graphs.size == 1 && graphs.first.respond_to?(:status)
          bg_stat = graphs.first

          Rails.logger.info "Received background status progress: #{bg_stat.progress}%%"

          respond_to do |format|
            format.html { render :partial  => 'status_progress', :locals => {:progress => bg_stat.progress} }
            format.json  { render :json => {:progress => bg_stat.progress} }
          end

          return
        end

        # render
        graphs.each do |graph|
          label = limits_reached(graph)
          unless label.blank?
            if status.blank?
              status = _("Limits exceeded for ") + label
            else
              status += "; " + label
            end
          end
        end
        level = "error" unless status.blank?

      rescue ActiveResource::ClientError => error
	logger.warn error.inspect
        level = "error"
        ret_error = ClientException.new(error)
        refresh = false
      rescue ActiveResource::ServerError => error
	error_hash = Hash.from_xml error.response.body
        level = "error"
        refresh = false
	logger.warn error_hash.inspect
	if error_hash["error"] &&
          (error_hash["error"]["type"] == "SERVICE_NOT_RUNNING" ||
           error_hash["error"]["type"] == "COLLECTD_SYNC_ERROR")
           if error_hash["error"]["type"] == "COLLECTD_SYNC_ERROR"
             level = "warning"  #it is a warning only
             status = error_hash["error"]["description"]
           else
             status = _("Status not available")
           end
	else
           ret_error = ClientException.new(error)
	end
      end

      #Checking WebYaST service plugins
      begin
        plugins = Plugins.find(:all)
        plugins.each {|plugin|
          level = plugin.level if plugin.level == "error" || (plugin.level == "warning" && level == "ok")
          if status.blank?
            status = plugin.short_description
          else
            status += "; " + plugin.short_description
          end
        }
      rescue Exception => error
	logger.warn error.inspect
        level = "error"
        refresh = false
	error_hash = Hash.from_xml error.response.body
	if error_hash["error"] && error_hash["error"]["type"] == "NO_PERM"
          status = _("Status not available (no permissions)")
          level = "warning"  #it is a warning only
        else
          status = error_hash["error"]["description"]
        end
        ret_error = ClientException.new(error)
      end
    end #benchmark

    render(:partial => "status_summary",
           :locals => { :status => status, :level => level, :error => ret_error,
                        :refresh_timeout => (refresh ? refresh_timeout : nil) })
  end

  #
  # AJAX call for showing a single graph
  #
  def evaluate_values
    client_permissions
    group_id = params[:group_id]
    graph_id = params[:graph_id]
    till = Time.now
    data = Hash.new
    if  params.has_key? "minutes"
      data[:minutes] = params[:minutes].to_i
    else
      data[:minutes] = 5 #default last 5 minutes
    end
    from = till -  data[:minutes]*60

    begin
      ActionController::Base.benchmark("Graphs data read from the server") do
        graph = Graphs.find(group_id)
        available_metrics = Metrics.find(:all)
        data[:y_scale] = graph.y_scale.to_f
        data[:y_label] = graph.y_label
        data[:y_max] = graph.y_max
        data[:y_decimal_places] = graph.y_decimal_places
        data[:graph_id] = graph_id
        data[:group_id] = group_id
        data[:lines] = []
        data[:limits] = []
        graph_descriptions = graph.single_graphs.select{|gr| gr.headline == graph_id}
        unless graph_descriptions.empty?
          logger.warn "More than one graphs with the same haeadline #{graph_id}. --> taking first" if graph_descriptions.size > 1
          graph_description = graph_descriptions.first
          data[:cummulated] = graph_description.cummulated
          data[:linegraph] = graph_description.linegraph
          graph_description.lines.each do |line|
            original_metrics = available_metrics.select{|me| me.id[(me.host.size+1)..(me.id.size-1)] == line.metric_id}
            unless original_metrics.empty?
              logger.warn "More than one metrics with the same id found: #{line.metric_id}. --> taking first" if original_metrics.size > 1
              original_metric = original_metrics.first
              single_line = Hash.new
              single_line[:label] = line.label
              single_line[:values] = get_data(original_metric.id, line.attributes["metric_column"], from, till, data[:y_scale])

              #checking limit max
              if line.limits.max.to_i > 0
                limit_line = []
                limit_reached = ""
                single_line[:values].each do |entry|
                  limit_reached = _("exceeded") if entry[1] > line.limits.max.to_i
                  limit_line << [entry[0],line.limits.max.to_i]
                end
                if graph_description.cummulated == "false"
                  data[:limits] << {:reached => limit_reached, :values => limit_line, :label => line.label} #show it in an own line
                else
                  single_line[:limit_reached] = limit_reached unless limit_reached.blank? #just make it "red"
                end
              end
              #checking limit min
              if line.limits.min.to_i > 0
                limit_line = []
                limit_reached = ""
                single_line[:values].each do |entry|
                  limit_reached = _("undercut") if entry[1] < line.limits.min.to_i
                  limit_line << [entry[0],line.limits.min.to_i]
                end
                if graph_description.cummulated == "false"
                  data[:limits] << {:reached => limit_reached, :values => limit_line, :label => line.label} #show it in an own line
                else
                  single_line[:limit_reached] = limit_reached unless limit_reached.blank? #just make it "red"
                end
              end
              data[:lines] << single_line
            end
          end
        else
          logger.error "No description for #{group_id}/#{graph_id} found."
        end
      end

      #flatten the data of all lines to the same amount of entries
      min_hash = data[:lines].min {|a,b| a[:values].size <=> b[:values].size }
      count = min_hash[:values].size
      data[:lines].each do |line|
        #strip to the same length
        while line[:values].size > count
          line[:values].pop
        end
      end

      logger.debug "Rendering #{data.inspect}"

      render :partial => "status_graph", :locals => { :data => data, :error => nil }
      rescue Exception => error
	logger.warn error.inspect
        render :partial => "status_graph", :locals => { :data => nil, :error => ClientException.new(error) }
    end
  end

  def edit
    client_permissions
    begin
      ActionController::Base.benchmark("Graph information from server") do
        @graphs = Graphs.find(:all)
      end
      #sorting graphs via id
      @graphs.sort! {|x,y| y.id <=> x.id }
    rescue Exception => error
      logger.warn error.inspect
      flash[:error] = YaST::ServiceResource.error(error)
      redirect_to :controller=>"status", :action=>"index" and return
    end
  end

  def save
    client_permissions
    begin
      ActionController::Base.benchmark("Graph information from server") do
        @graphs = Graphs.find(:all)
      end
    rescue Exception => error
      logger.warn error.inspect
      flash[:error] = YaST::ServiceResource.error(error)
      redirect_to :controller=>"status", :action=>"index" and return
    end

    @graphs.each do |graph|
      dirty = false
      params.each_pair{|key, value|
        slizes = key.split "/"
        if slizes.size == 4 && slizes[0] == "value"
          #searching the limit entry in the graph
          next if graph.id != slizes[1]
          graph.single_graphs.each do |single_graph|
            next if single_graph.headline != slizes[2]
            single_graph.lines.each do |line|
              next if line.label != slizes[3]
              #have limit with value --> setting values based on the corresponding min/max flag
              min_max = params["measurement/" +  slizes[1] + "/" +slizes[2] + "/" + slizes[3]]
              old_min = line.limits.min
              old_max = line.limits.max
              if value.empty?
                line.limits.min = "0"
                line.limits.max = "0"
              else
                if min_max == "max"
                  line.limits.max = value
                  line.limits.min = "0"
                elsif min_max == "min"
                  line.limits.max = "0"
                  line.limits.min = value
                end
              end
              dirty = true if old_min != line.limits.min || old_max != line.limits.max
            end
          end
        end
      }
      response = false
      if dirty
        Rails.logger.debug "New graph: #{graph.inspect}"
        graph.save
      end
    end

    flash[:notice] = _("Limits have been written.")
    redirect_to :controller=>"status", :action=>"index"
  end

  private

  def refresh_timeout
    # default refresh timeout is 5 minutes
    timeout = ControlPanelConfig.read 'system_status_timeout', 5*60

    if timeout.zero?
      Rails.logger.info "System status autorefresh is disabled"
    else
      Rails.logger.info "Autorefresh system status after #{timeout} seconds" # RORSCAN_ITL
    end

    return timeout
  end

end

