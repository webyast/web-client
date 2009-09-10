require 'yast/service_resource'

class PatchUpdatesController < ApplicationController

  before_filter :login_required
  layout 'main'
  include ProxyLoader
  # GET /patch_updates
  # GET /patch_updates.xml
  def index
    @patch_updates = load_proxy 'org.opensuse.yast.system.patches', :all
    logger.debug "Available patches: #{@patch_updates.inspect}"
  end

  # this action is rendered as a partial, so it can't throw
  def show_summary
    error = nil
    patch_updates = nil    
    begin
      patch_updates = load_proxy 'org.opensuse.yast.system.patches', :all
    rescue Exception => e
      error = e
      patch_updates = nil
    end

    patches_summary = nil

    if patch_updates
      patches_summary = { :security => 0, :important => 0, :optional => 0}

      [:security, :important, :optional].each do |patch_type|
        patches_summary[patch_type] = patch_updates.find_all { |p| p.kind == patch_type.to_s }.size
      end
    else
      erase_redirect_results #reset all redirects
      erase_render_results
      flash.clear #no flash from load_proxy
    end

    respond_to do |format|
      format.html { render :partial => "patch_summary", :locals => { :patch => patches_summary, :error => error } }
      format.json  { render :json => patches_summary }
    end    
  end

  def load_filtered
    @patch_updates = load_proxy 'org.opensuse.yast.system.patches', :all
    kind = params[:value]
    unless kind == "all"
      @patch_updates = @patch_updates.find_all { |patch| patch.kind == kind }
    end
    render :partial => "patches"
  end

  # POST /patch_updates/1
  # POST /patch_updates/1.xml

  def install    
    update_array = []

    #search for patches and collect the ids
    params.each { |key, value|
      if key =~ /\D*_\d/
        update_array << value
      end
    }
    update_array.each do |patch_id|
      update = load_proxy 'org.opensuse.yast.system.patches', patch_id
      
      if update
        begin
          update.save
          logger.debug "updated #{patch_id}"
          flash[:notice] = _("Patch has been installed.")
        rescue ActiveResource::ClientError => e
          flash[:error] = YaST::ServiceResource.error(e)
          ExceptionLogger.log_exception e
        end        
      end
  end
    redirect_to({:controller=>"patch_updates", :action=>"index"})
  end
end
