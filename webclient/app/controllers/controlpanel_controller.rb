#
# Control panel
#
# This is the default controller for webclient
#

require 'yaml'

class ControlpanelController < ApplicationController

  before_filter :ensure_login

  def index
    @shortcuts = shortcuts_data
    check_update
  end

  def show_all
    @shortcut_groups = {}
    shortcuts_data.each do |name, data|
      data["groups"].each do |group|
        @shortcut_groups[group] = Array.new unless @shortcut_groups.include?(group)
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
  
  protected

  # FIXME: refactor out to updates_controller !
  #
  # Check patches
  def check_update
    proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.patches')
    # FIXME: check proxy
    begin
      patch_updates = proxy.find(:all) || []
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      return
    rescue Exception => e
      flash[:error] = "An exception was raised. Check the logs."
      logger.error e
      return
    end
    
    security = 0
    important = 0
    optional = 0
    patch_updates.each do |patch|
      case patch.kind
        when "security":  security += 1
        when "important": important += 1
        when "optional":  optional += 1
      end
    end
    # FIXME: Don't create label, create a partial view instead
    # FIXME: translations !
    label = ""
    label += "Security Updates: #{security} " if security>0
    label += "Important Updates: #{important} " if important>0
    label += "Optional Updates: #{optional} " if optional>0

    label = _("Your system is up to date.") if label.blank?
    
    # FIMXE: Images are defined by CSS, don't hardcode them here
    if security>0 || important>0
      img = "/images/button_critical.png"
    elsif optional>0
      img = "/images/button_warning.png"
    else
      img = "/images/button_ok.png"
    end
    logger.debug "evaluated patches #{patch_updates.inspect} ==> security:#{security}; important:#{important}; optional:#{optional}"
  end

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
end
