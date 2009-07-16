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

  def show_summary
    patch_updates = load_proxy 'org.opensuse.yast.system.patches', :all

    unless patch_updates
      flash.clear #no flash from load_proxy
      render :partial => "patch_summary", :locals => { :patch => nil }
      return false
    end

    patches = { :security => 0, :important => 0, :optional => 0}

    patch_updates.each do |patch|
      case patch.kind
        when "security":  patches[:security] += 1
        when "important": patches[:important] += 1
        when "optional":  patches[:optional] += 1
      else
        logger.warn "unknown patch kind #{patch.kind}"
      end
    end

    render :partial => "patch_summary", :locals => { :patch => patches }
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
