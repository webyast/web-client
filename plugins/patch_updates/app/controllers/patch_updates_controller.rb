require 'yast/service_resource'
require 'client_exception'

class PatchUpdatesController < ApplicationController

  before_filter :login_required
  layout 'main'
  include ProxyLoader

private

  def check_registration
    registration = nil
    begin
      registration = load_proxy 'org.opensuse.yast.modules.registration.registration'
    rescue
      registration = nil
    end
    return true if registration && registration.respond_to?('guid')
    return false
  end  

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_patch_updates"

public

  # GET /patch_updates
  # GET /patch_updates.xml
  def index
    @patch_updates = load_proxy 'org.opensuse.yast.system.patches', :all
    flash[:warning] = _("Your system is NOT registered. Please run registration in order to get updates.") unless check_registration
    logger.debug "Available patches: #{@patch_updates.inspect}"
  end

  # this action is rendered as a partial, so it can't throw
  def show_summary
    error = nil
    patch_updates = nil    
    begin
      patch_updates = load_proxy 'org.opensuse.yast.system.patches', :all
    rescue Exception => e
      error = ClientException.new(e)
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
      format.html { render :partial => "patch_summary", :locals => { :patch => patches_summary, :error => error, :registered => check_registration } }
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

  # POST /patch_updates/start_install_all
  # Starting installation of all proposed patches
  def start_install_all
    logger.debug "Start installation of all patches"

    respond_to do |format|
      format.html { render :partial => "patch_installation", :locals => { :patch => _("Installing all patches..."), :error => nil  , :go_on => true }}
    end    
  end

  def stop_install_all
    logger.debug "Stopping installation of all patches"

    respond_to do |format|
      format.html { render :partial => "patch_installation", :locals => { :patch => _("Installation stopped"), :error => nil  , :go_on => false }}
    end    
  end

  # POST /patch_updates/install_all
  # Install each patch. This function will be called periodically from the controll center
  def install_all
    logger.debug "Installing one available patch...."

    error = nil
    patch_updates = nil    
    begin
      patch_updates = load_proxy 'org.opensuse.yast.system.patches', :all
    rescue Exception => e
      error = e
      patch_updates = nil
    end

    flash.clear #no flash from load_proxy
    last_patch = ""
    unless patch_updates.blank?
      #installing the first available patch
      logger.info "Installing patch :#{patch_updates[0].name}"
      begin
        patch_updates[0].save
        logger.debug "updated #{patch_updates[0].name}"
      rescue ActiveResource::ResourceNotFound => e
        flash[:error] = YaST::ServiceResource.error(e)
      rescue ActiveResource::ClientError => e
        error = e
      end        
      last_patch = patch_updates[0].name
    else
      erase_redirect_results #reset all redirects
      erase_render_results
    end

    respond_to do |format|
      if last_patch.blank?
        format.html { render :partial => "patch_installation", :locals => { :patch => _("Installation finished"), :error => error  , :go_on => false }}
      else
        format.html { render :partial => "patch_installation", :locals => { :patch => _("%s installed.") % last_patch , :error => error }}
      end
    end    
  end

  # POST /patch_updates/install
  # Installing one or more patches which has given via param 

  def install    
    update_array = []

    #search for patches and collect the ids
    params.each { |key, value|
      if key =~ /\D*_\d/ || key == "id"
        update_array << value
      end
    }
    update_array.each do |patch_id|
      update = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.patches').new(
                             :repo=>nil, 
                             :kind=>nil, 
                             :name=>nil, 
                             :arch=>nil, 
                             :version=>nil,
                             :summary=>nil, 
                             :resolvable_id=>patch_id)
      begin
        update.save
        logger.debug "updated #{patch_id}"
        flash[:notice] = _("Patch has been installed.")
      rescue ActiveResource::ResourceNotFound => e
        flash[:error] = YaST::ServiceResource.error(e)
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
      end        
    end
    redirect_to({:controller=>"patch_updates", :action=>"index"})
  end
end
