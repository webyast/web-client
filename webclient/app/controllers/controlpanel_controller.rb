#
# Control panel
#
# This is the default controller for webclient
#

require 'yaml'

class ControlpanelController < ApplicationController
  include ProxyLoader
  before_filter :ensure_login
  before_filter :ensure_wizard, :only => [:nextstep, :backstep]

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

  # POST /controlpanel/select_language
  # setting language for translations
  def select_language
    respond_to do |format|
      format.html { render :partial => "select_language" }
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


  # nextstep and backstep expect, that wizard session variables are set
  def ensure_wizard
    if !Basesystem.in_process?(session)
       redirect_to "/controlpanel"
    end
  end


  def nextstep
    Basesystem.next_step session
    unless Basesystem.done? session
      redirect_to Basesystem::current_target(session)
    else
      proxy = YaST::ServiceResource.proxy_for 'org.opensuse.yast.modules.basesystem'
      basesystem = proxy.find
      # this is just for saving network bandwidth, the steps list will not be saved
      basesystem.steps = []
      basesystem.finish = true
      basesystem.save
      redirect_to "/controlpanel"
    end    
  end

  def backstep
    Basesystem.back_step session
    redirect_to Basesystem.current_target( session)
  end

  # when triggered by button/link from basesystem, shows current module from session
  def thisstep
    redirect_to Basesystem.current_target( session)
  end

  protected

  # reads the shortcuts and returns the
  # hash with the data
  def shortcuts_data
    # save shortcuts in the Hash
    # each shortcuts file has each plugin shortcut named
    # by a key, we return the same key but namespaced with the plugin
    # name like pluginname:shortcutkey
    shortcuts = {}
    # read shortcuts from plugins
    #logger.debug Rails::Plugin::Loader.all_plugins.inspect
    #logger.debug Rails.configuration.load_paths
    YaST::LOADED_PLUGINS.each do |plugin|
      logger.debug "looking into #{plugin.directory}"
      shortcuts.merge!(plugin_shortcuts(plugin))
    end
    logger.debug shortcuts.inspect
    shortcuts
  end
  
  # reads shortcuts of a specific plugin directory
  def plugin_shortcuts(plugin)
    shortcuts = {}
    shortcuts_fn = File.join(plugin.directory, 'shortcuts.yml')
    if File.exists?(shortcuts_fn)
      logger.debug "Shortcuts at #{plugin.directory}"
      shortcutsdata = YAML::load(File.open(shortcuts_fn))
      return nil unless shortcutsdata.is_a? Hash
      # now go over each shortcut and add it to the modules
      shortcutsdata.each do |k,v|
        # use the plugin name and the shortcut key as
        # the new key
        shortcuts["#{plugin.name}:#{k}"] = v
      end
    end
    shortcuts
  end
  

  # Checks if basic system module should be shown instead of control panel
  # and if it should, then also redirects to that module.
  # TODO check if controller from config exists
  def need_redirect
    if Basesystem.initialized?(session)
      # session variable is used to find out, if basic system module is needed
      return false if Basesystem.done? session
      # error happen during basesystem, so show this page (prevent endless loop bnc#554989) 
      render :action => "basesystem"
      return true
    else
      proxy = YaST::ServiceResource.proxy_for 'org.opensuse.yast.modules.basesystem'
      return false unless proxy
      basesystem = proxy.find
      return false unless basesystem
      Basesystem.initialize(basesystem,session)
      return false if Basesystem::done? session
      logger.info "start basesystem setup"
      redirect_to Basesystem.current_target(session)
      return true
    end
  end
end
