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
    # For singleton resources you can use p.find with no arguments
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
      resource = nil
      begin
        resource = self.resource_for_interface(interface_name)
        raise "null resource, should throw inside resource_for_interface" unless resource
      rescue Exception => e
        Rails.logger.warn e
        return nil
      end
      
      proxy = self.class_for_resource(resource, opts)
      
      if block_given?
        yield proxy
      end
      return proxy
    end

    # returns back the rest-service error message if the HTTP error 4** happens
    def self.error(net_error)
      begin
        h = Hash.from_xml(net_error.response.body)["error"]
      rescue NoMethodError
        h = { "message" => net_error.response.body }
      end

      return h.nil? ? h : h["message"]
    end

    # all dynamic proxies are created under this module
    module Proxies
    end
    
    # place to hold data related to the
    # current connected web service
    module Session
      # service we are logged in to
      mattr_accessor :site
      # login used to access the site
      mattr_accessor :login
      # auth_token from session
      mattr_accessor :auth_token
    end

    # ActiveResource::Base class is broken with singleton resources
    # therefore we add some to it
    #
    # See: https://rails.lighthouseapp.com/projects/8994/tickets/2608-activeresource-support-for-singleton-resources#ticket-2608-1
    def self.fix_singleton_proxy(obj)
      # singularize only if the name is plural
      obj.collection_name = obj.collection_name.singularize if ( obj.collection_name == obj.collection_name.pluralize)
      #end
      
      def obj.element_path(id, prefix_options = {}, query_options = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        # original: "#{prefix(prefix_options)}#{collection_name}/#{id}.#{format.extension}#{query_string(query_options)}"
        "#{prefix(prefix_options)}#{collection_name}.#{format.extension}#{query_string(query_options)}"
      end

      # overriding the collection_path to omit the extension and make the collection_name singular
      def obj.collection_path(prefix_options = {}, query_options = nil)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        # original: "#{prefix(prefix_options)}#{collection_name}.#{format.extension}#{query_string(query_options)}"
        "#{prefix(prefix_options)}#{collection_name}.#{format.extension}#{query_string(query_options)}"
      end
    end

    # add the convenience methods to the proxy object
    # like permissions and resource_uri
    def self.add_service_proxy_convenience_methods(obj)
      class << obj
        
        def resource_uri
          URI.join(self.site.to_s, File.join(self.site.path,"#{self.element_name}.xml"))
        end

        # dynamic implementation of permissions as described
        # on proxy_for documentation
        def permissions(opts={})
          login = opts.has_key?(:user) ? opts[:user] : YaST::ServiceResource::Session.login
          raise "Can't retrieve permissions. No user specified and not logged in" if not login
          perm_resource = OpenStruct.new(:href => '/permissions', :singular => false, :interface => 'org.opensuse.yast.webservice.permissions')
          proxy = YaST::ServiceResource.class_for_resource(perm_resource)
          
          raise "object does not implement any interface" if not (self.respond_to?(:interface) and self.interface)
          ret = Hash.new
          interface_name = self.interface
          begin
            permissions = proxy.find(:all, :params =>
                { :user_id => login, :filter => interface_name })
          rescue
            raise "Cannot find permission for user #{login} and interface #{interface_name}"
          end
          RAILS_DEFAULT_LOGGER.warn "#{proxy.element_name} #{proxy.site}"
          permissions.each do |perm|
            break if perm.name.nil? # no permissions
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
    #
    # This method creates a dynamic class based on
    # ActiveResource::Base, and preconfigured
    # with the path where the resource is on
    # the server based on /resources.xml introspection.
    #
    # the dynamic class is defined in YaST::ServiceResource::Proxies
    # and it is named after the interface:
    # org.foo.bar -> OrgFooBar
    # If the class exists, then if it is the same resource path, it
    # is reused. If it is not the same resource path, then the name
    # is modified until an unique name is found.
    #
    def self.class_for_resource(resource, opts={})
      # dynamically create an anonymous class for
      # this resource
      path = resource.href

      name = File.basename(path)
      base_path = File.dirname(path)

      # use options site if available, otherwise
      # the ServiceResource site
      site = opts.fetch(:site,
        Session.site.nil? ?
          ActiveResource::Base.site : Session.site)
      raise "Invalid site" if site.nil?
      full_site = URI.join(site.to_s, base_path)
      
      rsrc = nil
      # the module where we store the proxy classes
      proxy_mod = YaST::ServiceResource::Proxies
      if not resource.interface.blank?
        counter = 0
        while true
          klass_name = "#{resource.interface.split('.').last.camelize}".to_sym
          #klass_name = "#{resource.interface.split('.').last.camelize}#{(counter < 1) ? "" : counter}".to_sym
          
          #klass_name = "#{resource.interface.tr('.', '_').camelize}#{(counter < 1) ? "" : counter}".to_sym
          if proxy_mod.const_defined?(klass_name)
            rsrc = proxy_mod.const_get(klass_name)
            # if the class has the same path, use it, otherwise, go to next
            # name
            if not "#{rsrc.site}" == "#{full_site}"
              # undefine it, we use send because remove_const is
              # private, yes black magic
              proxy_mod.send(:remove_const, klass_name)
              # set it again
              rsrc = Class.new(ActiveResource::Base)
              proxy_mod.const_set(klass_name, rsrc)
              break
              #counter = counter + 1
              # get a new name
              #next
            else
              # otherwise just use the old class
              break
            end
          else
            # the current name does not exist
            rsrc = Class.new(ActiveResource::Base)
            proxy_mod.const_set(klass_name, rsrc)
            break
          end
        end
      else
        rsrc = Class.new(ActiveResource::Base)
      end

      rsrc.site = full_site
      rsrc.element_name = name.to_s
      
      # add convenience method
      self.add_service_proxy_convenience_methods(rsrc)
      # if the resource is a singleton add the necessary
      # black magic
      self.fix_singleton_proxy(rsrc) if resource.singular?

      # set the interface name of the proxy
      # that is used when retrieving permissions
      rsrc.instance_variable_set(:@interface, resource.interface)
      rsrc.instance_variable_set(:@singular, resource.singular?)
      rsrc.password = Session.auth_token if not Session.auth_token.blank?
      
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
