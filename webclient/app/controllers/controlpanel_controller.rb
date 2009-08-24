#
# Control panel
#
# This is the default controller for webclient
#

require 'yaml'

class ControlpanelController < ApplicationController
  include ProxyLoader
  before_filter :ensure_login

  def index
    return false if need_redirect
    @shortcuts = shortcuts_data
  end

  def show_all
    @shortcut_groups = {}
    shortcuts_data.each do |name, data|
      data["groups"].each do |group|
        @shortcut_groups[group] ||= Array.new
        @shortcut_groups[group] << data
      end
    end
  end

  # this action allows to retrieve the shortcuts
  # as a resource
  def shortcuts
    respond_to do |format|
      format.html { } 
      format.xml  { render :xml => shortcuts_data.to_xml, :location => "none" }
      format.json { render :json => shortcuts_data.to_json, :location => "none" }
    end
  end


  def nextstep
    steps = session[:wizard_steps].split ","
    if (steps.last == session[:wizard_current])
      proxy = YaST::ServiceResource.proxy_for 'org.opensuse.yast.modules.basesystem'
      basesystem = proxy.find
      basesystem.current = FINAL_STEP
      basesystem.steps = []
      basesystem.save
      session[:wizard_current] = FINAL_STEP
    else
      session[:wizard_current] = steps[steps.index(session[:wizard_current])+1]
    end
    redirect_to "/controlpanel"
  end

  def backstep
    steps = session[:wizard_steps].split ","
    if session[:wizard_current] != steps.first
      session[:wizard_current] = steps[steps.index(session[:wizard_current])-1]
    end
    redirect_to "/controlpanel"
  end

  protected

  # reads the shortcuts and returns the
  # hash with the data
  def shortcuts_data
    # save shortcuts in the Hash
    # each shortcuts file has each plugin shortcut named
    # by a key, we return the same key but namespaced with the plugin
    # name like pluginname:shortcutkey
    s = {}
    # read shortcuts from plugins
    #logger.debug Rails::Plugin::Loader.all_plugins.inspect
    #logger.debug Rails.configuration.load_paths
    YaST::LOADED_PLUGINS.each do |plugin|
      logger.debug "looking into #{plugin.directory}"
      s.merge!(plugin_shortcuts(plugin))
    end
    logger.debug s.inspect
    s
  end
  
  # reads shortcuts of a specific plugin directory
  def plugin_shortcuts(plugin)
    s = {}
    shortcuts = File.join(plugin.directory, 'shortcuts.yml')
    if File.exists?(shortcuts)
      logger.debug "Shortcuts at #{plugin.directory}"
      shortcutsdata = YAML::load(File.open(shortcuts))
      return nil unless shortcutsdata.is_a? Hash
      # now go over each shortcut and add it to the modules
      shortcutsdata.each do |k,v|
        # use the plugin name and the shortcut key as
        # the new key
        s["#{plugin.name}:#{k}"] = v
      end
    end
    s
  end
  
  # Constant that signalizes, that all steps from base system setup are done
  # This constant and constant in rest-service -> basesystem.rb are not connected
  # and do not have to be the same value
  FINAL_STEP = "FINISH"
  # Checks if basic system module should be shown instead of control panel
  # and if it should, then also redirects to that module.
  # TODO check if wizard from config exists
  def need_redirect
    if session[:wizard_current]
      # session variable is used to find out, if basic system module is needed
      return false if session[:wizard_current] == FINAL_STEP
      # basic system setup in progress => redirect to current module
      redirect_to :controller => session[:wizard_current]
      return true
    else
      basesystem = load_proxy 'org.opensuse.yast.modules.basesystem'
      unless basesystem
        erase_redirect_results #reset all error redirects
        erase_render_results #erase all error render
        flash.clear #no error flash from load_proxy
        logger.warn "Error occured during loading basesystem information"
        return false
      end

      if basesystem.steps.empty? or basesystem.current == basesystem.final_step
        session[:wizard_current] = FINAL_STEP
        return false
      end
      # we got some steps from backend, base system setup is not over and 
      # no sign of progress in session variables => restart base system setup
      logger.debug basesystem.steps.inspect
      session[:wizard_steps] = basesystem.steps.join(",")
      session[:wizard_current] = basesystem.steps.first
      redirect_to :controller => basesystem.steps.first
      return true
    end
  end
end
