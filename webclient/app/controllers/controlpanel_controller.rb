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
    logger.debug "next step in base system"
    proxy = YaST::ServiceResource.proxy_for 'org.opensuse.yast.modules.basesystem'
    basesystem = proxy.find
    basesystem.current = session[:wizard_mode]
    basesystem.save
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
  
  # Constant that signalize, that all steps from base system settings is done
  # +warn+: must be synchronized with same constant in base system module
  FINAL_STEP = "FINISH"
  # Checks if basic system modul need show another module instead control panel
  def need_redirect
    session[:wizard_mode] = nil #clean wizard mode request from session
    basesystem = load_proxy 'org.opensuse.yast.modules.basesystem'
    unless basesystem
      erase_redirect_results #reset all error redirects
      erase_render_results #erase all error render
      flash.clear #no error flash from load_proxy
      logger.warn "Error occure during loading basesystem information"
      return false
    end

    return false if basesystem.current.upcase == FINAL_STEP

    session[:wizard_mode] = basesystem.current
    redirect_to :controller => basesystem.current
    return true
  end
end
