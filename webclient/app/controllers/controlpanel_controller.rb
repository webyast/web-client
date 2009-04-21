
require 'yaml'

class ControlpanelController < ApplicationController
  
  def index
    # no control panel for unlogged users
    if not logged_in?
      redirect_to '/login'
    end

    # go over all modules
    # @config = YAML::load(File.open("#{RAILS_ROOT}/config/config.yml"))    
    #File.join(RAILS_ROOT, 'config', 'config.yml')
    
    # do we allow erb templating? :-)
    # @config = YAML::load(ERB.new(IO.read(File.join(RAILS_ROOT, 'config', 'config.yml'))).result)[RAILS_ENV]

    @modules = fake_modules
    logger.debug @modules.inspect
  end

  # this action generates the data for the available
  # modules based on the data of the service
  # which is available on session[controllers]
  # (bad name?)
  #
  # once we know which servces are there,
  # we match them with the available client
  # controllers
  def modules
    # the service -> client module matching can be made
    # mucho more intelligent later, for now, match
    # the modules we know about.
    client = []
    
    # we save the data here, that is how jimmac's template
    # expect the data (like fake-data.js)
    modules = Hash.new

    if session.has_key?(:controllers)
      session[:controllers].each do |key, controller|
        mod = Hash.new

        mod[:title] = controller.description
        mod[:description] = controller.description
        mod[:title] = controller.description

        next if key.nil?
      
        case key
          when "services"
            mod[:icon] = 'icons/yast-online_update.png'
          when "language"
            mod[:icon] = 'icons/yast-language.png'
          when "users"
            mod[:icon] = 'icons/yast-users.png'
          when "permissions"
            mod[:icon] = 'icons/yast-security.png'
          when "patch_updates"
            mod[:icon] = 'icons/yast-package-manager.png'
          when "systemtime"
            mod[:icon] = 'icons/yast-ntp-client.png'
          else
            mod[:icon] = 'icons/yast-misc.png'
          end
          # TODO add the tags from the REST service that kkaempf
          # mentioned
          mod[:tags] = ['IP', 'network', 'IPv4', 'device', 'eth', 'wi-fi', 'ethernet', 'cable', 'card']
          # we dont have groups yet ups?
          mod[:groups] = ['network']
          mod[:url] = key
          mod[:favorite] = true

          modules[key] = mod
        end
      end
      respond_to do |format|
        format.html { render  } 
        format.xml  { render :xml => modules.to_xml, :location => "none" }
        format.json { render :json => (params[:fake] == "1" ? self.fake_modules : modules.to_json), :location => "none" }
      end
    end

  def fake_modules
    { :services=> {
    :title => 'Configure services',
    :description=> 'Unix services',
    :icon => 'icons/yast-online_update.png',
    :tags => ['IP', 'network', 'IPv4', 'device', 'eth', 'wi-fi', 'ethernet', 'cable', 'card'],
    :groups => ['network'],
    :url =>  'services',
    :favorite =>  true
    } ,:language => {
    :title => 'Languages',
    :description => 'Configure languages',
    :icon => 'icons/yast-language.png',
    :tags => ['locale', 'country', 'language', 'idiom'],
    :groups => ['Regional'],
    :url =>  'languages',
    :favorite => true
      },:systemtime => {
    :title => 'Time',
    :description => 'Configure time',
    :icon => 'icons/yast-ntp-client.png',
    :url =>  'systemtime',
    :tags => ['clock', 'time', 'ntp'],
    :groups => ['services','network'],
      }
    }
  end
  
end
