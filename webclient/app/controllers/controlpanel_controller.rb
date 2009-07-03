
require 'yaml'

class ControlpanelController < ApplicationController

  # this action allows to retrieve the shortcuts
  # as a resource
  def shortcuts
    respond_to do |format|
      format.html { } 
      format.xml  { render :xml => shortcuts_data.to_xml, :location => "none" }
      format.json { render :json => shortcuts_data.to_json, :location => "none" }
    end
  end
  
  def index
    # no control panel for unlogged users
    if not logged_in?
      redirect_to :controller => :sessions, :action => :new
      return
    else
      logger.debug "We are logged in"
    end

    @shortcuts = shortcuts_data
    check_update
  end

  def show_all
    # no control panel for unlogged users
    if not logged_in?
      redirect_to :controller => :sessions, :action => :new
      return
    else
      logger.debug "We are logged in"
    end

    @shortcut_groups = {}
    shortcuts_data.each do |name, data|
      data["groups"].each do |group|
        if @shortcut_groups.has_key? (group)
          @shortcut_groups[group] << data
        else
          @shortcut_groups[group] = [data]
        end
      end
    end
  end

  protected

  # Check patches
  def check_update
    @proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.patches')
    begin
      patch_updates = @proxy.find(:all) || []
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
    end
    
    @security = 0
    @important = 0
    @optional = 0
    patch_updates.each do |patch|
      case patch.kind
        when "security"
           @security += 1
        when "important"
           @important += 1
        when "optional"
           @optional += 1
      end
    end
    @label = ""
    @label += "Security Updates: #{@security} " if @security>0
    @label += "Important Updates: #{@important} " if @important>0
    @label += "Optional Updates: #{@optional} " if @optional>0

    @label = _("Your system is up to date.") if @label.blank?
    if @security>0 || @important>0
      @img = "/images/button_critical.png"
    elsif @optional>0
      @img = "/images/button_warning.png"
    else
      @img = "/images/button_ok.png"
    end
    logger.debug "evaluated patches #{patch_updates.inspect} ==> security:#{@security}; important:#{@important}; optional:#{@optional}"
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
    return s
  end
  
  # reads shortcuts of a specific plugin directory
  def plugin_shortcuts(plugin)
    s = {}
    shortcuts = File.join(plugin.directory, 'shortcuts.yml')
    if File.exists?(shortcuts)
      logger.debug "Shortcuts at #{plugin.directory}"
      shortcutsdata = YAML::load(File.open(shortcuts))
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
