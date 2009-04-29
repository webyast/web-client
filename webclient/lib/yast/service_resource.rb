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
    def self.proxy_for(interface_name, opts={})
      # not used yet
      # {:site => ActiveResource::Base::, :arg_two => 'two'}.merge!(opts)
      path = self.path_for_interface(interface_name)
      return nil if path.nil?      
      proxy = self.class_for_resource(path, opts)
      if block_given?
        yield proxy
      end
      return proxy
    end

    # place to hold data related to the
    # current connected web service
    module Session
      mattr_accessor :site
    end

    # Creates a class for a resource based on
    # the interface name
    def self.class_for_resource(path, opts={})
      class_name = name.to_s.camelize
      #class_name = name.to_s
      rsrc = Class.new(ActiveResource::Base) do
        name = File.basename(path)

        # use options site if available, otherwise
        # the ServiceResource site
        site = opts.fetch(:site,
                          Session.site.nil? ?
                          ActiveResource::Base.site : Session.site)

        self.site = "#{site}#{File.dirname(path)}"
        self.element_name = name.to_s
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
