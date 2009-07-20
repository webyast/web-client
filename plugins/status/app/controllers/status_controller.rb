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

  def create_data_map( tree, label = "")
    data_list = []
    if tree.methods.include?("attributes")
      tree.attributes.each do |key, branch|
        if key.start_with?("t_") 
          data_list << branch.to_f
        elsif key == "limit"
          @limits[label] = branch.attributes
        else        
          next_label = label
          if key != "value"
            next_label += "/" + key
          end
          data_list = create_data_map(branch, next_label) 
          if data_list.size > 0
             @data[next_label] = data_list
             data_list = []
          end
        end
      end
    else
      logger.error "wrong result: #{tree.inspect}"
    end
    return data_list
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
      
      status = @client.find(:dummy_param, :params => { :start => from.to_i.to_s, :stop => till.to_i.to_s })

      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
        return false
    end

    create_data_map status

    #grouping graphs to memory, cpu,...
    @data.each do |key, list_value|
      if @limits.has_key?(key)
        graph_list = []
        for i in 0..list_value.size-1 do
           graph_list << [i,@limits[key]["value"]]
        end
        @limits_list[key] = graph_list
      end

      key_split = key.split("/")
      if key_split.size > 1
        group_map = {}
        group_map = @data_group[key_split[1]] if @data_group.has_key?(key_split[1])
        label_name = ""
        for i in 2..key_split.size-1 do
          if i==2 
            label_name = key_split[i]
          else
            label_name += "/" + key_split[i]
          end
        end
        graph_list = []
        store_data = false #take only a list which has one value greater than 0 at least
        for i in 0..list_value.size-1
          store_data = true if list_value[i] != 0
          value_list = [i]
          if key_split[1]=="memory" # take MByte for the value
            value_list << list_value[i]/1024/1024
          else
            value_list << list_value[i]
          end
          graph_list << value_list
        end
        if store_data
          group_map[label_name] = graph_list
          @data_group[key_split[1]] = group_map
        end
      else
        logger.error "empty key: #{@key} #{list.inspect}"
      end
#      logger.debug "System information: #{@data_group[key_split[1]].inspect}"
    end
    logger.debug "Limits: #{@limits.inspect}"
    true
  end

  #removing logging data and add limits which are defined in params
  def create_save_data(status, params, label = "")
    status.each do |key, value|
     if key.start_with?("t_") 
       status.delete(key)  
     elsif
       next_label = label+ "/" + key

       create_save_data(value, params, next_label) if value.is_a? Hash
     end
    end
    if params.has_key?(label+"/value")
      limit = Hash.new
      limit["value"] = params[label+"/value"]
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
    create_data()
  end

  def index
    return unless client_permissions
    create_data()

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end


  def save
    return unless client_permissions
    create_data()

    status = @client.find()
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
