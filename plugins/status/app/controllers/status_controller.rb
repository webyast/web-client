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


  def create_data_map(tree)
    tree.attributes["metric"].each{ |metric|
      metric_name = metric.name
      group = metric.metricgroup
      @data_group[group] ||= Hash.new
      interval = metric.interval #TODO: not used yet
      starttime = metric.starttime
      case metric.attributes["label"]
      when YaST::ServiceResource::Proxies::Status::Metric::Label # one label
        write_data_group(metric.attributes["label"], group, metric_name)
      when Array # several label
        metric.attributes["label"].each{ |label|
          write_data_group(label, group, metric_name)
      }
      end
    }
  end

  def create_data(from = nil, till = nil, background = false)
    @limits_list = Hash.new
    @limits_list[:reached] = String.new
    @data_group = Hash.new
    status = []
    
    till ||= Time.new
    from ||= till - 300 #last 5 minutes
    ActionController::Base.benchmark("Status data read from the server") do
      stat_params = { :start => from.to_i.to_s, :stop => till.to_i.to_s }
      stat_params[:background] = "true" if background
      status = @client_status.find(:dummy_param, :params => stat_params )
    end

    # this is a background status result
    return status.attributes if status.attributes.keys.sort == ["progress", "status", "subprogress"]

    create_data_map status
#    logger.debug @data_group.inspect

    #checking if there is one valid data entry at least
    found = false
    @data_group.each do |key, map|
      map.each do |graph_key, list_value|
         unless list_value.empty?
           found = true
           break
         end
      end
      break if found
    end
    found
  end


 # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_status"

  public

  def initialize
  end

  def edit
    return unless client_permissions
    flash[:notice] = _("No data found for showing system status.") unless create_data
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

  def show_summary
    return unless client_permissions
    begin
      till = params['till']
      from = params['from']

      till ||= Time.new.to_i
      from ||= till - 300 #last 5 minutes

      result = create_data(from, till, !params['background'].nil?)

      # is it a background progress?
      if result.class == Hash
        status_progress = result.symbolize_keys
        Rails.logger.debug "Received background status progress: #{status_progress.inspect}"

        respond_to do |format|
          format.html { render :partial  => 'status_progress', :locals => {:status => status_progress, :from => from, :till => till } }
          format.json  { render :json => status_progress }
        end

        return
      end

      level = "ok"
      status = ""
      ActionController::Base.benchmark("Status data read from the server") do
        graphs = @client_graphs.find(:all, :params => { :checklimits => true })
        graphs ||= []
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
