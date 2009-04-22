
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
    Dir.entries(File.join(RAILS_ROOT, 'vendor', 'plugins')).each do |entry|
      # skip . and ..
      next if entry =~ /^\./
      
      plugindir = File.join(RAILS_ROOT, 'vendor', 'plugins', entry)
      shortcuts = File.join(plugindir, 'shortcuts.yml')
      if File.exists?(shortcuts)
        shortcutsdata = YAML::load(File.open(shortcuts))
        # now go over each shortcut and add it to the modules
        shortcutsdata.each do |k,v|
          # use the plugin name and the shortcut key as
          # the new key
          s["#{entry}:#{k}"] = v
        end
      end
    end
    return s
  end
  
end
