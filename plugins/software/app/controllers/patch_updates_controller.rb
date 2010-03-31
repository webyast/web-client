require 'yast/service_resource'
require 'client_exception'

class PatchUpdatesController < ApplicationController

  before_filter :login_required
  layout 'main'
  include ProxyLoader

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_software"

  # GET /patch_updates
  # GET /patch_updates.xml
  def index
    begin
      @patch_updates = load_proxy 'org.opensuse.yast.system.patches', :all
    rescue ActiveResource::ServerError => e
      ce = ClientException.new e
      if ce.backend_exception_type ==  "PACKAGEKIT_ERROR"
        flash[:error] = ce.message
        @patch_updates = []
        @error = true
      else
        raise e
      end
    end
    logger.debug "Available patches: #{@patch_updates.inspect}"
  end

  # this action is rendered as a partial, so it can't throw
  def show_summary
    error = nil
    patch_updates = nil
    begin
      patch_updates = load_proxy 'org.opensuse.yast.system.patches', :all, {:background => params['background']}
    rescue ActiveResource::UnauthorizedAccess => e
      # handle unauthorized error - the session timed out
      Rails.logger.error "Error: ActiveResource::UnauthorizedAccess"
      error = e
      error_string = ''
    rescue ActiveResource::ClientError => e
      error = ClientException.new(e)
      patch_updates = nil
      error_string = _("A problem occured when loading patch information.")
    rescue ActiveResource::ServerError => e
      error = ClientException.new(e)
      error_string = _("A problem occured when loading patch information.")
      error_string = error.message if error.backend_exception_type ==  "PACKAGEKIT_ERROR"
      patch_updates = nil
    end    
    patches_summary = nil

    if patch_updates
      # is it a background progress?
      if patch_updates.size == 1 && patch_updates.first.respond_to?(:status)
        bg_stat = patch_updates.first

        patches_status = {:status => bg_stat.status, :progress => bg_stat.progress, :subprogress => bg_stat.subprogress}
        Rails.logger.debug "Received background patches progress: #{patches_status.inspect}"

        respond_to do |format|
          format.html { render :partial  => 'patch_progress', :locals => {:status => patches_status, :error => error} }
          format.json  { render :json => patches_status }
        end

        return
      else
        patches_summary = { :security => 0, :important => 0, :optional => 0}

        [:security, :important, :optional].each do |patch_type|
          patches_summary[patch_type] = patch_updates.find_all { |p| p.kind == patch_type.to_s }.size
        end
      end
    else
      erase_redirect_results #reset all redirects
      erase_render_results
      flash.clear #no flash from load_proxy
    end

    # don't refresh if there was an error
    ref_timeout = error ? nil : refresh_timeout

    respond_to do |format|
      format.html { render :partial => "patch_summary", :locals => { :patch => patches_summary, :error => error, :error_string => error_string, :refresh_timeout => ref_timeout } }
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
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
      end        
    end
    redirect_to({:controller=>"controlpanel", :action=>"index"})
  end

  private

  def refresh_timeout
    # the default is 24 hours
    timeout = ControlPanelConfig.read 'patch_status_timeout', 24*60*60

    if timeout.zero?
      Rails.logger.info "Patch status autorefresh is disabled"
    else
      Rails.logger.info "Autorefresh patch status after #{timeout} seconds"
    end

    return timeout
  end

end
