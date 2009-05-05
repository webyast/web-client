#equire 'active_resource/struct'

module YaST
  #SERVICE_SITE = "http://localhost:8080"
  module ServiceResource    
    #
    # Creates a proxy for a given interface
    #
    # YaST::ServiceResource.proxy_for('org.iface.foo') do |p|
    #   p.find(:all)
    # end
    #
    # For singleton resources you can use find(:one)
    #
    # The path of the resource is asked to the server resource
    # registry
    #
    # By default, the service used is the one stored in
    # YaST::ServiceResource::Session which can be overriden
    #
    # proxy_for('org.iface.foo', :site => "http://foo") do |p|
    #  ...
    # end
    #
    # If YaST::ServiceResource::Session does not specify anything
    # and site not overriden, ActiveResource::Base.site is used.
    #
    # ==Permissions==
    #
    # YaST::ServiceResource.proxy_for('org.iface.foo') do |p|
    #   p.permissions
    # end
    #
    # returns the permissions for the current interface
    # on the server side.
    #
    # permissions returns a hash permission-name => granted
    # example: { :read => true, :write => false }
    #
    # Options: :user => 'value' will retrieve the permissions
    # for the specified user.
    #
    # If no user is specified, the current logged user will be
    # retrieved from YaST::ServiceResource::Session and used
    # instead.
    #
    # Note that if you manually specify an user, you should have
    # permissions to read those user permissions.
    #
    def self.proxy_for(interface_name, opts={})
      # not used yet
      # {:site => ActiveResource::Base::, :arg_two => 'two'}.merge!(opts)
      path = self.path_for_interface(interface_name)
      return nil if path.nil?
      proxy = self.class_for_resource(path, opts)
      
      # set the interface name of the proxy
      # that is used when retrieving permissions
      proxy.interface = interface_name
      
      if block_given?
        yield proxy
      end
      return proxy
    end

    # place to hold data related to the
    # current connected web service
    module Session
      # service we are logged in to
      mattr_accessor :site
      # login used to access the site
      mattr_accessor :login
    end

    # Creates a class for a resource based on
    # the interface name
    def self.class_for_resource(path, opts={})
      # dynamically create an anonymous class for
      # this resource
      rsrc = Class.new(ActiveResource::Base) do
        name = File.basename(path)
        base_path = File.dirname(path)

        # use options site if available, otherwise
        # the ServiceResource site
        site = opts.fetch(:site,
                          Session.site.nil? ?
                          ActiveResource::Base.site : Session.site)

        self.site = URI.join(site, base_path)
        self.element_name = name.to_s

        # ActiveResource::Base class is broken with singleton resources
        # therefore we add some to it
        #
        # See: https://rails.lighthouseapp.com/projects/8994/tickets/2608-activeresource-support-for-singleton-resources#ticket-2608-1
        class << self

          # this find_one, unlike ActiveResource one, works
          # without :from for a singleton resource
          def find_one(options)
            if not options.has_key?(:from)
              if not self.element_name == self.element_name.pluralize
                # it is a singleton
                # create the :from options from the resource
                # path
                # URI is sick.
                # URI.join http://localhost/foo, bar -> http://localhost/bar
                # URI.join http://localhost, foo/bar -> http://localhost/foo/bar
                # so join the path before to avoid this sick behavior
                resource_uri = URI.join(self.site.to_s, File.join(self.site.path,"#{self.element_name}.xml"))
                return super(:from => resource_uri.path)
              else
                raise "Can't find :one in non singleton resource"
              end
            else
              # delegate to ActiveResource
              super(options)
            end
          end
          
          # wrapper for find, for the singleton case
          def find(*arguments)
            scope   = arguments.slice!(0)
            options = arguments.slice!(0) || {}

            case scope
              when :one then return self.find_one(options)
              else return super(scope, options)
            end
          end

          # dynamic implementation of permissions as described
          # on proxy_for documentation
          def permissions(opts={})
            login = opts.has_key?(:user) ? opts[:user] : YaST::ServiceResource::Session.login
            if login
              proxy = YaST::ServiceResource.class_for_resource("/permissions")
              if self.respond_to?(:interface) and self.interface
                interface_name = self.interface
                permissions = proxy.find(:all, :user_id => login, :filter => interface_name)
                ret = Hash.new
                permissions.each do |perm|
                  # the permission name is an extension
                  # of the interface name, if the
                  # interface is not a subset of the permission
                  # something wrong happened with the query
                  # and we should ignore it
                  next if not perm.name.include?(interface_name)
                  perm_short_name = perm.name
                  perm_short_name.slice!("#{interface_name}.")
                  # to this point the short name must be something
                  next if perm_short_name.blank?
                  ret[perm_short_name.to_sym] = perm.grant
                end
                return ret
              else
                raise "Resource does not implement any interface. Can't retrieve permissions"
              end
        
            else
              raise "Can't retrieve permissions. No user specified and not logged in"
            end
          end

          # Accessor for the interface we implement
          def interface=(interface_name)
            @interface = interface_name
          end
          
          def interface
            defined?(@interface) ? @interface : nil
          end
          
        end

        
        # do not export the class to namespace
        #Object.const_set("#{class_name}#{Time.now.to_i}".intern, rsrc)
      end
    end

    # returns the url for a given interface by
    # querying the remote resource registry
    # (the resources resource)
    def self.path_for_interface(interface_name)
      proxy = self.class_for_resource("/resources")
      resources = proxy.find(:all)
      resources.each do |resource|
        return resource.href if resource.interface == interface_name
      end
      return nil
    end
  
    # Obsolete
    # Just for backward compatibility for resources
    # using YaST::ServiceResource::Base
    class Base < ActiveResource::Base
      # This method is called by Account after a session is
      # created to use the connected service as default
      def self.init_service_url(url)
        self.site = url
      end
     
      # This method is called by Account after a session is
      # created to use the connected service auth as default
      def self.set_web_service_auth (auth_token)
        self.password = auth_token
        self.user = ""
      end      
    end

  end
end
