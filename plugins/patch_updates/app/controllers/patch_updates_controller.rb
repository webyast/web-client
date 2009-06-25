require 'yast/service_resource'

class PatchUpdatesController < ApplicationController

  before_filter :login_required
  layout 'main'

  # GET /patch_updates
  # GET /patch_updates.xml
  def index
    set_permissions(controller_name)
  end

  def list
    proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.patches')
    begin
      @patch_updates = proxy.find(:all) || []
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
    end
    respond_to do |format|
      format.html { render :partial => 'patches' }
      format.js { render :partial => 'patches' }
      format.xml  { render :xml => @patch_updates }
      format.json { render :json => @patch_updates.to_json }
    end
  end

  # POST /patch_updates/1
  # POST /patch_updates/1.xml

  def install
    proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.patches')
    ok = true
    update_array = []

    params.each_pair{ |key, value|
      if key.include?("patch_")
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
      flash[:notice] = _("Patches have been installed.") if ok
    end
    }
    redirect_to({:controller=>"patch_updates", :action=>"index"})
  end
=begin

  def install
    proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.patches')
    ok = true
    begin
      update = proxy.find(params[:id])
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
        ok = false
    end

    if ok
      begin
        ok = update.save
        rescue ActiveResource::ClientError => e
          flash[:error] = YaST::ServiceResource.error(e)
          ok = false
      end
      flash[:notice] = _("Patch has been installed.") if ok
    end
    redirect_to({:controller=>"patch_updates", :action=>"index"})
  end
=end
end
