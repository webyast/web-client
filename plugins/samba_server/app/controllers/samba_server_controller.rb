require 'yast/service_resource'

class SambaServerController < ApplicationController

    before_filter :login_required
    layout 'main'
    helper 'view_helpers/html'

    def get_permissions 
	@client = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.sambashares')

	# TODO FIXME: this is a workaround, the REST API uses another rights internally
	tmp_interface = @client.interface
	@client.interface = 'org.opensuse.yast.modules.yapi.samba'
	@permissions = @client.permissions
	@client.interface = tmp_interface
    end

    private :get_permissions
 
    # GET /samba_server
    # GET /samba_server.xml
    def index
	get_permissions

	if @permissions[:getalldirectories]
	    @shares = @client.find(:all)
	else
	    @shares = []
	    flash[:error] = "No permission"
	end

	respond_to do |format|
	    format.html # samba_server/index.html.erb
	    format.xml  { render :xml => @shares }
	end
    end

    # GET /users/1/edit
    def edit
	get_permissions

	if @permissions[:editshare] || @permissions[:getshare]
	    @share = @client.find(params[:id])
	else
	    @share = {}
	    flash[:error] = _("Error: Permission denied")
	end
    end

    # GET /samba_server
    # GET /samba_server.xml
    def new
	get_permissions

	if @permissions[:addshare]
	    @share = @client.new(:id => nil)

	    # add empty default properties
	    defaults = {:parameters =>
		[
		    {"name"=>"path", "value"=>""},
		    {"name"=>"comment", "value"=>""},
		    {"name"=>"read only", "value"=>"No"},
		    {"name"=>"inherit acls", "value"=>"Yes"},
		]
	    }
	    
	    @share.load(defaults)
	else
	    flash[:error] = _("Error: Permission denied")
	end

	respond_to do |format|
	    format.html # new.html.erb
	    format.xml  { render :xml => @share }
	end
    end

    def create
	get_permissions

	if @permissions[:addshare]
	    @share = @client.new
	    debugger

	    # set the values
	    values = []

	    params[:share][:parameters].each do |name, value|
		values << { "name" => name, "value" => value }
	    end

	    # set the name
	    values << { "name" => "name", "value" => params[:share][:id] }

	    values = { "parameters" => values }

	    @share.load(values)

	    # save the new share
	    @share.save

	    flash[:notice] = _("Share '#{@share.id}' has been added.")
	else
	    flash[:error] = _("Error: Permission denied")

	    respond_to do |format|
	      format.html { redirect_to :action => :index }
	      format.xml  { head :forbidden }
	    end
	end

	respond_to do |format|
	    format.html { redirect_to :action => :index }
	    format.xml  { head :ok }
	end
    end


    # PUT /users/1
    # PUT /users/1.xml
    def update
	get_permissions

	if @permissions[:editshare]
	    @share = @client.find(params[:id])

	    respond_to do |format|
		response = true

		begin
		    do_updating = false

		    @share.parameters.each do |p|
			# update parameters
			new_value = params[:parameters][p.name]

			if new_value != p.value
			    logger.debug "Share '#{@share.id}': updating #{p.name} from '#{p.value}' to '#{new_value}'"
			    p.value = new_value
			    do_updating = true
			end
		    end

		    # save the new values
		    if do_updating
			response = @share.save
		    end

		rescue ActiveResource::ClientError => e
		    flash[:error] = YaST::ServiceResource.error(e)
		    response = false
		end

		if response
		    flash[:notice] = do_updating ? _("Share '#{@share.id}' has been successfully updated.") : _("Share '#{@share.id}' has not been changed.")
	
		    format.html { redirect_to :action => :index }
		    format.xml  { head :ok }
		else
		    format.html { render :action => :edit }
		    format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
		end
	    end
	end
    end

    # DELETE /users/1
    # DELETE /users/1.xml
    def delete
	get_permissions

	if @permissions[:deleteshare]
	    @share = @client.find(params[:id])

	    begin
		@share.destroy
		flash[:notice] = _("Share '#{@share.id}' has been successfully deleted.")
	    rescue ActiveResource::ClientError => e
		msg = YaST::ServiceResource.error(e)

		if msg.nil?
		    msg = _("Error: ") + e.to_s
		end

		flash[:error] = msg
	    end

	    respond_to do |format|
	      format.html { redirect_to :action => :index }
	      format.xml  { head :ok }
	    end
	else
	    flash[:error] = _("Error: Permission denied")

	    respond_to do |format|
	      format.html { redirect_to :action => :index }
	      format.xml  { head :forbidden }
	    end

	end
    end

end
