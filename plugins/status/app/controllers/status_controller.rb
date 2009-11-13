require 'yast/service_resource'
require 'client_exception'
require 'open-uri'

class StatusController < ApplicationController
  include ProxyLoader
  
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
          if not @limits_list[key][:min][0].nil? and value[1] < @limits_list[key][:min][0][1]\
             or not @limits_list[key][:max][0].nil? and value[1] > @limits_list[key][:max][0][1]
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
    metric_name += "/" + label.name if label.name != "value" #more than one labels of a group
    values = label.attributes["values"]
    if values.uniq != ["invalid"] #use only entries which have at least one valid value
      value_size = values.length
      divisor = (group == "memory")? 1024*1024 : 1 # take MByte for the value
      data_list = Array.new
      value_size.times{|t| data_list << [t,values[t].to_f/divisor]}
      if group == "df"
        data_list.reject! {|value| value[1] == 0 } #df returns sometime 0 entries
        data_list = [[0,0]] if data_list.empty? #it is really 0 :-)
      end
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
    else
      logger.debug "#{group} #{metric_name} #{label.name} has no valid entry"
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
    
    till = Time.new
    from = till - 300 #last 5 minutes
    ActionController::Base.benchmark("Status data read from the server") do
      status = @client.find(:dummy_param, :params => { :start => from.to_i.to_s, :stop => till.to_i.to_s })
    end
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
    flash[:notice] = _("No data found for showing system status.") unless found

    true
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

    log = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.logs')
    @logs = log.find(:all) 
    
    create_data
    limits_reached
    logger.debug "limits reached for #{@limits_list[:reached].inspect}"
  end


  def show_summary
    return unless client_permissions
    begin
      create_data
      status = limits_reached
      status = (_("Limits exceeded for %s") % status) unless status.empty?
      render :partial => "status_summary", :locals => { :status => status, :error => nil }
    rescue Exception => error
      erase_redirect_results #reset all redirects
      erase_render_results
      render :partial => "status_summary", :locals => { :status => nil, :error => ClientException.new(error) } and return
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
	@client.create( :limits=>limits.to_xml(:root => "limits") ) 
      end
    rescue Exception => ex
      flash[:error] = _("Saving limits failed!")
      redirect_to :controller=>"status", :action=>"edit" and return
    end

    redirect_to :controller=>"status", :action=>"index"
  end

end
