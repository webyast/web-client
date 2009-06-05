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
	    @share = @client.new(:name => nil, :path => nil)
	else
	    flash[:error] = _("Error: Permission denied")
	end

	respond_to do |format|
	    format.html # new.html.erb
	    format.xml  { render :xml => @share }
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
		    #response = @share.save
		rescue ActiveResource::ClientError => e
		    flash[:error] = YaST::ServiceResource.error(e)
		    response = false
		end

		if response
		    flash[:notice] = _("Share '#{@share.name}' has been successfully updated.")
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
		flash[:notice] = _("Share '#{@share.name}' has been successfully deleted.")
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
