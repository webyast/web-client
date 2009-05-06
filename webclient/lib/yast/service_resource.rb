require 'ostruct'

module YaST

  # Provides utilities to interact with a YaST webservice
  #
  # Session module is used to hold the current session with
  # a YaST web service
  #
  # proxy_for function allows to retrieve a proxy implementing
  # a certain interface, using introspection to the webservice
  # to find the resource url.
  # The returned proxy is also able to handle singleton resources
  # and to instrospect permissions for the current user.
  #
  # Base is a compatibility ActiveResource::Base like class
  # for fixed url resources
  #
  module ServiceResource    
    #
    # Creates a proxy for a given interface
    #
    # YaST::ServiceResource.proxy_for('org.iface.foo') do |p|
    #   p.find(:all)
    # end
    #
    # For singleton resources you can use p.get, p.save, p.destroy
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
      resource = self.resource_for_interface(interface_name)
      return nil if resource.nil?
      proxy = self.class_for_resource(resource, opts)
      
      # set the interface name of the proxy
      # that is used when retrieving permissions
      proxy.interface = interface_name
      if resource.singular?
        class << proxy
          def singular?
            true
          end
        end
      else
        class << proxy
          def singular?
            false
          end
        end
      end
      #proxy.singular = resource.singular
      
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

    # ActiveResource::Base class is broken with singleton resources
    # therefore we add some to it
    #
    # See: https://rails.lighthouseapp.com/projects/8994/tickets/2608-activeresource-support-for-singleton-resources#ticket-2608-1
    # this methods replaces find_one, delete, create and update
    def self.fix_singleton_proxy(obj)
      class << obj
        # this find_one, unlike ActiveResource one, works
        # without :from for a singleton resource
        def find_one(options)
          # we need to fix find_one only if the :from key is
          # not given
          if not options.has_key?(:from)
            # it is a singleton
            # create the :from options from the resource
            # path
            # URI is sick.
            # URI.join http://localhost/foo, bar -> http://localhost/bar
            # URI.join http://localhost, foo/bar -> http://localhost/foo/bar
            # so join the path before to avoid this sick behavior
            single_element = super(:from => resource_uri.path)
            # Now we need to redefine the delete and save methods of
            # the singleton element because of course ActiveResource can't
            # handle it

            #class << single_element.class
            #  def destroy
            #    connection.delete(self.resource_uri.path, self.class.headers)
            #  end
            #  
            #  def create
            #    connection.post(resource_uri.path, encode, self.class.headers).tap do |response|
            #      load_attributes_from_response(response)
            #    end
            #  end
            # 
            #  def update
            #    connection.put(self.resource_uri, encode, self.class.headers).tap do |response|
            #      load_attributes_from_response(response)
            #    end
            #  end
                #######
            #end
            return single_element
          else
            # if :from is present, then
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
      end
    end

    # add the convenience methods to the proxy object
    # like permissions and resource_uri
    def self.add_service_proxy_convenience_methods(obj)
      class << obj
        def get(options={})
          @single_element = find(:one, :from => resource_uri.path)
        end

        def destroy
          connection.delete(self.resource_uri.path, @single_element.class.headers)
        end
        
        def save
          get if not defined?(@single_element)
          connection.put(self.resource_uri.path, @single_element.encode, @single_element.class.headers).tap do |response|
            if response['Content-Length'] != "0" && response.body.strip.size > 0
              @single_element.load(@single_element.class.format.decode(response.body))
            end
          end
        end
        
        def resource_uri
          URI.join(self.site.to_s, File.join(self.site.path,"#{self.element_name}.xml"))
        end

        # dynamic implementation of permissions as described
        # on proxy_for documentation
        def permissions(opts={})
          login = opts.has_key?(:user) ? opts[:user] : YaST::ServiceResource::Session.login
          raise "Can't retrieve permissions. No user specified and not logged in" if not login
          perm_resource = OpenStruct.new(:href => '/permissions', :singular => false)
          proxy = YaST::ServiceResource.class_for_resource(perm_resource)
          raise "object does not implement any interface" if not (self.respond_to?(:interface) and self.interface)
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
        end

        # Accessor for the interface we implement
        def interface=(interface_name)
          @interface = interface_name
        end
          
        def interface
          defined?(@interface) ? @interface : nil
        end

        def singular=(singular)
          @singular = singular
        end
          
        def singular?
          defined?(@singular) ? @singular : false
        end
          
      end

    end
    
    # Creates a class for a resource based on
    # the interface name
    def self.class_for_resource(resource, opts={})
      # dynamically create an anonymous class for
      # this resource
      path = resource.href
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
        # do not export the class to namespace
        #Object.const_set("#{class_name}#{Time.now.to_i}".intern, rsrc)
      end
      # add convenience method
      self.add_service_proxy_convenience_methods(rsrc)
      # if the resource is a singleton add the necessary
      # black magic
      self.fix_singleton_proxy(rsrc) if resource.singular?
      return rsrc
    end

    # returns the url for a given interface by
    # querying the remote resource registry
    # (the resources resource)
    def self.resource_for_interface(interface_name)
      res_resource = OpenStruct.new(:href => '/resources', :singular => false)

      proxy = self.class_for_resource(res_resource)
      resources = proxy.find(:all)
      resources.each do |resource|
        return resource if resource.interface == interface_name
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
