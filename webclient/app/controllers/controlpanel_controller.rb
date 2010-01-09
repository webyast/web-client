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
    if !Basesystem.new.load_from_session(session).in_process?
       redirect_to "/controlpanel"
    end
  end


  def nextstep
    redirect_to Basesystem.new.load_from_session(session).next_step
  end

  def backstep
    redirect_to Basesystem.new.load_from_session(session).back_step
  end

  # when triggered by button/link from basesystem, shows current module from session
  def thisstep
    redirect_to Basesystem.new.load_from_session(session).current_step
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
    bs = Basesystem.new.load_from_session(session)
    if bs.initialized?
      # session variable is used to find out, if basic system module is needed
      return false if Bs.completed?
      # error happen during basesystem, so show this page (prevent endless loop bnc#554989) 
      render :action => "basesystem"
      return true
    else
      bs = Basesystem.find session
      return false if bs.completed?
      logger.info "start basesystem setup"
      redirect_to bs.current_step
      return true
    end
  end
end
