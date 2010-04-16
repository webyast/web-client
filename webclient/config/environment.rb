# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
# RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'yast/rack/static_overlay'

init = Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'UTC'

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  config.gem "locale_rails"
  config.gem "gettext_activerecord"
  config.gem "gettext_rails"

  # reload all plugins, changes in *.rb files take effect immediately
  # it's here because of https://rails.lighthouseapp.com/projects/8994/tickets/2324-configreload_plugins-true-only-works-in-environmentrb
  config.reload_plugins = true if ENV['RAILS_ENV'] == 'development'

  # In order to prevent unloading of AuthenticatedSystem
  config.load_once_paths += %W( #{RAILS_ROOT}/lib )
  # allows to find plugin in development tree locations
  # avoiding installing plugins to see them
  config.plugin_paths << File.join(RAILS_ROOT, '..', 'plugins')

  # add extra plugin path - needed during RPM build
  # (webyast-base-ui is already installed in /srv/www/... but plugins are
  # located in /usr/src/packages/... during build)
  config.plugin_paths << '/usr/src/packages/BUILD' unless ENV['ADD_BUILD_PATH'].nil?

  # In order to overwrite,exchange images, stylesheets,.... for special vendors there
  # is the directory "vendor" in the "public" directory. Each file in the public
  # directory can be exchanged by putting a file with the same path in the vendor 
  # directory.
  # Please take care that all links in the views have to be defined by the AssetTagHelper like
  # image_tag, stylesheet_link_tag, javascript_include_tag, ...
  config.action_controller.asset_host = Proc.new do |source, request|
    path = "#{config.root_path}/public/vendor#{source}".split("?")
    if path.length >0 and File.exists?(path[0]) 
      "#{request.protocol}#{request.host_with_port}/vendor"
    else
      ""
    end
  end

end

# Enforce https and pass cookie only via https
ActionController::Base.session_options[:session_secure] = true if ENV['RAILS_ENV'] == 'production'

# save loaded plugins, which are used to scan shortcuts laters
module YaST
end
YaST::LOADED_PLUGINS = init.loaded_plugins

# look for all existing loaded plugin's public/ directories
plugin_assets = init.loaded_plugins.map { |plugin| File.join(plugin.directory, 'public') }.reject { |dir| not (File.directory?(dir) and File.exist?(dir)) }
init.configuration.middleware.use YaST::Rack::StaticOverlay, :roots => plugin_assets
