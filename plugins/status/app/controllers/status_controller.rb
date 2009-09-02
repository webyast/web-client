require 'yast/service_resource'

class StatusController < ApplicationController
  before_filter :login_required
  layout "main"

  private
  def client_permissions
    @client = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.status')
    unless @client
      flash[:notice] = _("Invalid session, please login again.")
      redirect_to( logout_path ) and return
    end
    @permissions = @client.permissions
  end

  def write_data_group(label, group, metric_name, limits=nil)
    data_list = Array.new
    divisor = (group == "memory")? 1024*1024 : 1 # take MByte for the value
    count = 0
    data_list = label.map{ |v| count+=1; [count,v.to_f/divisor]}
    @data_group[group].merge!({metric_name => data_list})
    divisor = (group == "memory")? 1024*1024 : 1 # take MByte for the value
    @limits[label] = limits if limits #TODO: implement maximum and minimum format
#    @data["/#{group}/#{metric_name}/..."] = data_list
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
        limits = metric.attributes["limits"].attributes if metric.attributes.has_key? "limits"
        write_data_group(metric.attributes["label"].attributes["values"], group, metric_name, limits)
      when Array # several label
        metric.attributes["label"].each{ |l|
          limits = l.attributes["limits"].attributes if l.attributes.has_key? "limits"
          write_data_group(l.attributes["values"], group, metric_name, limits)
      }
      end
    }
  end

  def create_data
    @data = Hash.new
    @limits = Hash.new
    @limits_list = Hash.new
    @data_group = Hash.new
    status = []
    begin
      till = Time.new
      from = till - 300 #last 5 minutes
#puts File.read(@client.find(:dummy_param, :params => { :start => from.to_i.to_s, :stop => till.to_i.to_s }))
      status = @client.find(:dummy_param, :params => { :start => from.to_i.to_s, :stop => till.to_i.to_s })

      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
        return false
    end
    create_data_map status
=begin
    #grouping graphs to memory, cpu,...
    @data.each do |key, list_value|
      if @limits.has_key?(key)
        graph_list = []
        key_split = key.split("/")
        for i in 0..list_value.size-1 do
          if key_split.size>1 && key_split[1]=="memory" # take MByte for the value
            graph_list << [i,@limits[key]["value"]/1024/1024]
          else
            graph_list << [i,@limits[key]["value"]]
          end
        end
        @limits_list[key] = graph_list
      end

      key_split = key.split("/")
      if key_split.size > 1
        group_map = {}
      end
    end
=end
    # puts @data_group.inspect
    true
  end

  #removing logging data and add limits which are defined in params
  def create_save_data(status, params, label = "") #TODO: customize for new xml format
    status.each do |key, value|
     if key.start_with?("values")
       status.delete(key)
     elsif
       next_label = label+ "/" + key
       create_save_data(value, params, next_label) if value.is_a? Hash
     end
    end
    if params.has_key?(label+"/value")
      limit = Hash.new
      key_split = label.split("/")
      if key_split.size>1 && key_split[1]=="memory" # MByte for the value --> change it to Byte
        limit["value"] = params[label+"/value"].to_f*1024*1024
      else
        limit["value"] = params[label+"/value"]
      end
      limit["maximum"] = params[label+"/maximum"] == "true"?true:false
      status["limit"] = limit
    end
    return status
  end

 # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_status"

  public

  def initialize
  end

  def edit
    return unless client_permissions
    create_data
  end

  def index
    return unless client_permissions
    create_data
    @limit_hits = []
    @data_group.each do |key, map|
      map.each do |graph_key, list_value|
        limit_key = "/#{key}/#{graph_key}"
        if  @limits_list.has_key?(limit_key)
          cmp_value = @limits_list[limit_key][0][1] #take thatone cause it has already the right format
                                                 #( e.g. MByte for memory)
          list_value.each do |value|
            if (@limits[limit_key]["maximum"] && value[1]>= cmp_value) ||
               (!@limits[limit_key]["maximum"] && value[1]<= cmp_value)
              @limit_hits << limit_key
              break
            end
          end
        end
      end
    end
    logger.debug "limits reached for #{@limit_hits.inspect}"
  end


  def show_summary
    return unless client_permissions
    unless create_data
      erase_redirect_results #reset all redirects
      erase_render_results
      error = flash[:error]
      flash.clear #no flash from load_proxy
      render :partial => "status_summary", :locals => { :status => nil, :error => error }
      return false
    end
    status = ""
    @data_group.each do |key, map|
      error_found = false
      map.each do |graph_key, list_value|
        limit_key = "/#{key}/#{graph_key}"
        if  @limits_list.has_key?(limit_key)
          cmp_value = @limits_list[limit_key][0][1] #take thatone cause it has already the right format
                                                 #( e.g. MByte for memory)
          list_value.each do |value|
            if (@limits[limit_key]["maximum"] && value[1]>= cmp_value) ||
               (!@limits[limit_key]["maximum"] && value[1]<= cmp_value)
              error_found = true
              break
            end
          end
        end
      end
      if error_found
        status += "; " unless status.blank?
        if key == "df"
          status += _("Disk free limits exceeded")
        else
          status += key.capitalize + " " + _("limits exceeded")
        end
      end
    end

    render :partial => "status_summary", :locals => { :status => status, :error => nil }
  end

  def save
    return unless client_permissions
    begin
      till = Time.new
      from = till - 300 #last 5 minutes
      status = @client.find(:dummy_param, :params => {  :start => from.to_i.to_s, :stop => till.to_i.to_s })

      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
        redirect_to :controller=>"status", :action=>"edit"
        return false
    end

    save_hash = create_save_data(Hash.from_xml(status.to_xml)["status"], params)
    logger.debug "writing #{save_hash.inspect}"

    save_status = @client.new()
    save_status.load(save_hash)

    success = true
    begin
      save_status.save
      logger.debug "limits have been written"
      flash[:notice] = _("Limits have been written.")
    rescue ActiveResource::ClientError => e
       flash[:error] = YaST::ServiceResource.error(e)
       ExceptionLogger.log_exception e
       success = false
    end
    if success
      redirect_to :controller=>"status", :action=>"index"
    else
      redirect_to :controller=>"status", :action=>"edit"
    end
  end

end
