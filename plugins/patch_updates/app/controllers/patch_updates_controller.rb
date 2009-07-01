require 'yast/service_resource'

class PatchUpdatesController < ApplicationController

  before_filter :login_required
  layout 'main'

  # GET /patch_updates
  # GET /patch_updates.xml
  def index
    @proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.patches')
    begin
      @patch_updates = @proxy.find(:all) || []
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
    end
    logger.debug @patch_updates.nil?
  end

  # POST /patch_updates/1
  # POST /patch_updates/1.xml

  def install
    proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.patches')
    ok = true
    update_array = []

    #search for patches and collect the ids
    params.each { |key, value|
      if key =~ /\D*_\d/
        update_array << value
      end
    }
    update_array.each { |patch_id|
      begin
        update = proxy.find(patch_id)
        rescue ActiveResource::ClientError => e
          flash[:error] = YaST::ServiceResource.error(e)
          ok = false
      end

      if ok
        begin
          ok = update.save
          logger.debug "updated #{patch_id}"
          rescue ActiveResource::ClientError => e
            flash[:error] = YaST::ServiceResource.error(e)
            ok = false
        end
        flash[:notice] = _("Patch has been installed.") if ok
      end
    }
    redirect_to({:controller=>"patch_updates", :action=>"index"})
  end
end
