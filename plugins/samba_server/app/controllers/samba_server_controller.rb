require 'yast/service_resource'

class SambaServerController < ApplicationController

    before_filter :login_required
    layout 'main'
 
 
    # GET /samba_server
    # GET /samba_server.xml
    def index
	set_permissions(controller_name)
	@client = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.sambashares')
	@permissions = @client.permissions

	# FIXME: this is a workaround, this module uses another rights internally
	tmp_interface = @client.interface
	@client.interface = 'org.opensuse.yast.modules.yapi.samba'
	@permissions = @client.permissions
	@client.interface = tmp_interface

	@shares = @client.find(:all)

	respond_to do |format|
	    format.html # samba_server/index.html.erb
	    format.xml  { render :xml => @shares }
	end
    end


end
