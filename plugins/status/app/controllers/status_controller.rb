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

  def limits_reached
    @limits_list.each {|key, data|
      next if key == :reached
      keys = key.split "/"
      group = keys[1]
      metric_name = keys[2]

      if @data_group.has_key? group and @data_group[group].has_key? metric_name
        for value in @data_group[group][metric_name]
          if not @limits_list[key][:min][0][1].nil? and value[1] < @limits_list[key][:min][0][1]\
             or not @limits_list[key][:max][0][1].nil? and value[1] > @limits_list[key][:max][0][1]
            if key == "df"
              @limits_list[:reached] += _("Disk free limits exceeded;")
            else
              @limits_list[:reached] += key + ";"
            end
            break
          end
        end
      else
        logger.debug "error: metric not found"
      end
    }
    @limits_list[:reached]
  end

  def write_data_group(label, group, metric_name)
    values = label.attributes["values"]
    value_size = values.length
    divisor = (group == "memory")? 1024*1024 : 1 # take MByte for the value
    data_list = Array.new
    value_size.times{|t| data_list << [t,values[t].to_f/divisor]}
    @data_group[group].merge!({metric_name => data_list})

    limits = label.attributes["limits"]
    if limits
      @limits_list["/#{group}/#{metric_name}"] = {:min=>Array.new, :max=>Array.new}
      if label.attributes["limits"] and limits.attributes["min"] #limits.has_key? "min"
        minimum = limits.attributes["min"].to_f/divisor
        value_size.times{|i| @limits_list["/#{group}/#{metric_name}"][:min] << [i,minimum]}
      end
      if label.attributes["limits"] and limits.attributes["max"] #limits.has_key? "min"
        maximum = limits.attributes["max"].to_f/divisor
        value_size.times{|i| @limits_list["/#{group}/#{metric_name}"][:max] << [i,maximum]}
      end
    end
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

  def create_data
    @limits_list = Hash.new
    @limits_list[:reached] = String.new
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
    limits_reached
    logger.debug "limits reached for #{@limits_list[:reached].inspect}"
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
    status = limits_reached
    status = "limits exceeded for " + status unless status.empty?

    render :partial => "status_summary", :locals => { :status => status, :error => nil }
  end

  def save
    return unless client_permissions
    limits = Hash.new
    params.each_pair{|key, value|
      if key =~ /\/[-\w]*\/[-\w]*\/min/ # e.g /interface/if_packets-pan0/max
        unless value.empty?
          slizes = key.split "/"
          limits[slizes[1]] ||= Hash.new
          limits[slizes[1]][slizes[2]] ||= Hash.new
          limits[slizes[1]][slizes[2]].merge!(:min => value)
        end
      elsif key =~ /\/[-\w]*\/[-\w]*\/max/
        unless value.empty?
          slizes = key.split "/"
          limits[slizes[1]] ||= Hash.new
          limits[slizes[1]][slizes[2]] ||= Hash.new
          limits[slizes[1]][slizes[2]].merge!(:max => value)
        end
      end
    }

    puts "limits " + limits.inspect
#respond = @client.create(:params => params.inspect)
@client.create(:params => limits.inspect)
puts "respond: " + respond
#    respond = @client.put(:status, :params => params) #:status, {:params => params})
#    if respond == :success
#      redirect_to :controller=>"status", :action=>"index"
#    else
#      redirect_to :controller=>"status", :action=>"edit"
#    end
  end
=begin
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
=end
end
