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

  # this action allows to retrieve the shortcuts
  # as a resource
  def shortcuts
    respond_to do |format|
      format.html { } 
      format.xml  { render :xml => shortcuts_data.to_xml, :location => "none" }
      format.json { render :json => shortcuts_data.to_json, :location => "none" }
    end
  end


  # Constant that signalizes, that all steps from base system setup are done
  FINAL_STEP = "FINISH"
  # nextstep and backstep expect, that wizard session variables are set
  def ensure_wizard
    if session[:wizard_steps].nil? or session[:wizard_current].nil? or session[:wizard_current] == FINAL_STEP
       redirect_to "/controlpanel"
    end
  end


  def nextstep
    logger.debug "Wizard next step: current one: #{session[:wizard_current]} - steps #{session[:wizard_steps]}"
    steps = session[:wizard_steps].split ","
    if (steps.last != session[:wizard_current])
      session[:wizard_current] = steps[steps.index(session[:wizard_current])+1]
      logger.debug "Wizard next step: next one #{session[:wizard_current]}"
      redirect_to get_redirect_hash(session[:wizard_current])
    else
      proxy = YaST::ServiceResource.proxy_for 'org.opensuse.yast.modules.basesystem'
      basesystem = proxy.find
      # this is just for saving network bandwidth, the steps list will not be saved
      basesystem.steps = []
      basesystem.finish = true
      # basesystem.save will set always current to FINAL_STEP 
      basesystem.save
      session[:wizard_current] = FINAL_STEP
      logger.debug "Wizard next step: DONE"
      redirect_to "/controlpanel"
    end    
  end

  def backstep
    steps = session[:wizard_steps].split ","
    if session[:wizard_current] != steps.first
      session[:wizard_current] = steps[steps.index(session[:wizard_current])-1]
    end
    redirect_to get_redirect_hash(session[:wizard_current])
  end

  # when triggered by button/link from basesystem, shows current module from session
  def thisstep
    redirect_to get_redirect_hash(session[:wizard_current])
  end

  # display some message, that setup is not completed and that by clicking button
  # you start setting up the system
  def basesystem
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
      shortcuts_data = YAML::load(File.open(shortcuts_fn))
      return nil unless shortcuts_data.is_a? Hash
      # now go over each shortcut and add it to the modules
      shortcuts_data.each do |k,v|
        # use the plugin name and the shortcut key as
        # the new key
        shortcuts["#{plugin.name}:#{k}"] = v
      end
    end
    shortcuts
  end
  

  # Checks if basic system module should be shown instead of control panel
  # and if it should, then also redirects to that module.
  # TODO check if wizard from config exists
  def need_redirect
    if session[:wizard_current]
      # session variable is used to find out, if basic system module is needed
      return false if session[:wizard_current] == FINAL_STEP
      # basic system setup in progress => redirect to current module
      redirect_to :action => :basesystem
      return true
    else
      proxy = YaST::ServiceResource.proxy_for 'org.opensuse.yast.modules.basesystem'
      return false unless proxy
      basesystem = proxy.find
      return false unless basesystem
     
      if basesystem.steps.empty? or basesystem.finish
        session[:wizard_current] = FINAL_STEP
        return false
      end
      # we got some steps from backend, base system setup is not over and 
      # no sign of progress in session variables => restart base system setup
      logger.debug "Basesystem steps: #{basesystem.steps.inspect}"
      decoded_steps = basesystem.steps.collect { |step| step.action ? "#{step.controller}:#{step.action}" : step.controller  }
      session[:wizard_steps] = decoded_steps.join(",")
      session[:wizard_current] = decoded_steps.first
      redirect_to :action => :basesystem
      return true
    end
  end

  def get_redirect_hash (target)
    arr = target.split(":")
    ret = { :controller => arr[0], :action => arr[1]||"index"}
    logger.debug ret.inspect
    return ret
  end

end
