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

  def create_data ( tree, label)
    data_list = []
    tree.attributes.each do |key, branch|
      if key.start_with? ("t_") 
        data_list << branch.to_f
      else        
        next_label = label
        if key != "value"
          next_label += "/" + key
        end
        data_list = create_data (branch, next_label) 
        if data_list.size > 0
           @data[next_label] = data_list
           data_list = []
        end
      end
    end
   return data_list
  end

 # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_status"  

  public
  def initialize
  end


  def index
    return unless client_permissions
    @data = {}
    status = []
    begin
      till = Time.new
      from = till - 300 #last 5 minutes
      
      status = @client.find(:dummy_param, :params => { :start => from.strftime("%H:%M,%m/%d/%Y"), :stop => till.strftime("%H:%M,%m/%d/%Y") })
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
    end

    create_data ( status, "")

    #grouping graphs to memory, cpu,...
    @data_group = {}
    @data.each do |key, list_value|
      key_split = key.split("/")
      if key_split.size > 1
        group_map = {}
        group_map = @data_group[key_split[1]] if @data_group.has_key? (key_split[1])
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
          value_list << list_value[i]
          graph_list << value_list
        end
        if store_data
          group_map[label_name] = graph_list
          @data_group[key_split[1]] = group_map
        end
      else
        logger.error "empty key: #{@key} #{list.inspect}"
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
#    return unless client_status
  end
end
