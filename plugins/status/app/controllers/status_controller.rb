require 'yast/service_resource'
require 'client_exception'
require 'open-uri'

class StatusController < ApplicationController
  include ProxyLoader
  
  before_filter :login_required
  layout "main"

  private
  def client_permissions
    @client_status = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.status')
    @client_metrics = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.metrics')
    @client_graphs = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.graphs')
    unless @client_status && @client_graphs
      flash[:notice] = _("Invalid session, please login again.")
      redirect_to( logout_path ) and return
    end
    @permissions = @client_status.permissions
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
          label = group.id + "/" + single_graph.headline 
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
    status = @client_metrics.find(id, :params => stat_params )
    ret = Array.new

    case status.attributes["values"]
      when YaST::ServiceResource::Proxies::Metrics::Values # one entry
        status.values.value.collect!{|x| x.tr('\"','')} #removing \"
        status.values.value.size.times{|t| ret << [(status.values.start.to_i + t*status.values.interval.to_i)*1000, status.values.value[t].to_f/scale]} # *1000 --> jlpot evalutas MSec for date format
      when Array # several entries
        status.attributes["values"].each{ |value|
          if value.column == column_id
            value.value.collect!{|x| x.tr('\"','')} #removing \"
            value.value.size.times{|t| ret << [(value.start.to_i + t*value.interval.to_i)*1000, value.value[t].to_f/scale]} # *1000 --> jlpot evalutas MSec for date format
            break
          end
        }
    else
      logger.error "requesting collectdid #{id}/#{column_id} not found."
    end
    #strip zero values at the end of the array
    while ret.last && ret.last[1] == 0
      ret.pop
    end

    ret
  end


 # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_status"

  public

  def initialize
  end

  def ajax_log_custom
    # set the site to the view so it can load the log
    # dynamically
    if not params.has_key?(:id)
      raise "Unknown log file"
    end
    
#XXX FIXME Really ugly way how to use REST service
# should be something like find(:one, :from => params[:id], params => { :lines => lines })
    lines = params[:lines] || 5
    log_url = URI.parse(YaST::ServiceResource::Session.site.to_s)
    log_url = log_url.merge("logs/#{params[:id]}.xml?lines=#{lines}")
    logger.info "requesting #{log_url}"
    @content = open(log_url).read
    render :partial => 'status_log'
  end
  
  def index
    return unless client_permissions
    begin
      log = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.logs')
      @logs = log.find(:all) 
      @logs ||= {}
      @graphs = @client_graphs.find(:all, :params => { :checklimits => true })
      @graphs ||= []
      #sorting graphs via id
      @graphs.sort! {|x,y| y.id <=> x.id } 
      flash[:notice] = _("No data found for showing system status.") if @graphs.blank?
      rescue ActiveResource::ServerError => error
	error_hash = Hash.from_xml error.response.body
	logger.warn error_hash.inspect
	if error_hash["error"] && 
          (error_hash["error"]["type"] == "SERVICE_NOT_RUNNING" || 
           error_hash["error"]["type"] == "COLLECTD_SYNC_ERROR" ||
           error_hash["error"]["type"] == "NO_PERM")
           flash[:error] = error_hash["error"]["description"]
	else
           raise error
	end
    end
  end

  #
  # AJAX call for showing status overview
  #
  def show_summary
    return unless client_permissions
    begin
      level = "ok"
      status = ""
      ActionController::Base.benchmark("Graphs data read from the server") do
        graphs = @client_graphs.find(:all, :params => { :checklimits => true }) || []  
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
      end
      level = "error" unless status.blank?
      render :partial => "status_summary", :locals => { :status => status, :level => level, :error => nil }
      rescue ActiveResource::ClientError => error
	logger.warn error.inspect
        level = "error"
        render :partial => "status_summary", :locals => { :status => nil, :level => "error", :error => ClientException.new(error) } and return
      rescue ActiveResource::ServerError => error
	error_hash = Hash.from_xml error.response.body
        level = "error"
	logger.warn error_hash.inspect
	if error_hash["error"] && 
          (error_hash["error"]["type"] == "SERVICE_NOT_RUNNING" || 
           error_hash["error"]["type"] == "NO_PERM" ||
           error_hash["error"]["type"] == "COLLECTD_SYNC_ERROR")
           level = "warning" if error_hash["error"]["type"] == "COLLECTD_SYNC_ERROR" #it is a warning only
           status = error_hash["error"]["description"]
           render :partial => "status_summary", :locals => { :status => status, :level => level, :error => nil }
	else
           render :partial => "status_summary", :locals => { :status => nil, :level => level, :error => ClientException.new(error) } 
	end
    end
  end

  #
  # AJAX call for showing a single graph
  #
  def evaluate_values
    return unless client_permissions
    group_id = params[:group_id]
    graph_id = params[:graph_id]
    till ||= Time.new
    if params.has_key? "minutes"
      from = till -  params[:minutes].to_i*60
    else
      from = till -  300 #last 5 minutes
    end
    data = Hash.new
    
    begin
      ActionController::Base.benchmark("Graphs data read from the server") do
        @graph = @client_graphs.find(group_id)
        available_metrics = @client_metrics.find(:all)
        data[:y_scale] = @graph.y_scale.to_f
        data[:y_label] = @graph.y_label
        data[:graph_id] = graph_id
        data[:group_id] = group_id
        data[:lines] = []
        graph_descriptions = @graph.single_graphs.select{|gr| gr.headline == graph_id}
        unless graph_descriptions.empty?
          logger.warn "More than one graphs with the same haeadline #{graph_id}. --> taking first" if graph_descriptions.size > 1
          graph_description = graph_descriptions.first
          data[:cummulated] = graph_description.cummulated
          graph_description.lines.each do |line|
            original_metrics = available_metrics.select{|me| me.id[(me.host.size+1)..(me.id.size-1)] == line.metric_id}
            unless original_metrics.empty?
              logger.warn "More than one metrics with the same id found: #{line.metric_id}. --> taking first" if original_metrics.size > 1              
              original_metric = original_metrics.first
              single_line = Hash.new
              single_line[:label] = line.label
              single_line[:values] = get_data(original_metric.id, line.attributes["metric_column"], from, till, data[:y_scale])
              data[:lines] << single_line
            end
          end
        else
          logger.error "No description for #{group_id}/#{graph_id} found."
        end
      end
      logger.debug "Rendering #{data.inspect}"

      render :partial => "status_graph", :locals => { :data => data, :error => nil }
      rescue Exception => error
	logger.warn error.inspect
        render :partial => "status_graph", :locals => { :data => nil, :error => ClientException.new(error) }
    end
  end


  def save
    return unless client_permissions
    limits = Hash.new
    params.each_pair{|key, value|
      slizes = key.split "/"
      value = value.to_f*1024*1024 if !value.empty? && slizes[1]=="memory" #MByte for the value --> change it to Byte
      unless value.empty?
        if key =~ /\/[-\w]*\/[-\w]*\/min/ # e.g /interface/if_packets-pan0/max
          limits[slizes[1]] ||= Hash.new
          limits[slizes[1]][slizes[2]] ||= Hash.new
          limits[slizes[1]][slizes[2]].merge!(:min => value) 
        elsif key =~ /\/[-\w]*\/[-\w]*\/max/
          limits[slizes[1]] ||= Hash.new
          limits[slizes[1]][slizes[2]] ||= Hash.new
          limits[slizes[1]][slizes[2]].merge!(:max => value) unless value.empty?
        end
      end
    }

    Rails.logger.debug "New limits: #{limits.inspect}"

    begin
      ActionController::Base.benchmark("Limits saved on the server") do
        #This is a hack and will be removed when the status service has be replaced by the metric service
	@client_status.create( :limits=>limits.to_xml(:root => "limits") ) 
      end
    rescue Exception => ex
      flash[:error] = _("Saving limits failed!")
      redirect_to :controller=>"status", :action=>"edit" and return
    end

    redirect_to :controller=>"status", :action=>"index"
  end

end
