#equire 'active_resource/struct'

module YaST
  SERVICE_SITE = "http://localhost:8080"
    
  module ServiceResource

    # creates a proxy for a given interface
    #
    # YaST::ServiceResource::
    def self.proxy_for(interface_name)
      url = self.url_for_interface(interface_name)
      return nil if url.nil?
      
      proxy = Class.new(ActiveResource::Base)

      site = "#{SERVICE_SITE}#{File.dirname(url)}"
      name = File.basename(url)
      proxy = self.class_for_resource(name)
      return proxy
    end

    # Creates a class for a resource based on
    # the interface name
    def self.class_for_resource(name)
      class_name = name.to_s.camelize
      #class_name = name.to_s
      rsrc = Class.new(ActiveResource::Base) do
        self.site = SERVICE_SITE
        self.element_name = name.to_s
      end
      Object.const_set("#{class_name}#{Time.now.to_i}".intern, rsrc)
    end

    # returns the url for a given interface by
    # querying the remote resource registry
    # (the resources resource)
    def self.url_for_interface(interface_name)
      proxy = self.class_for_resource("resource")
      resources = proxy.find(:all)
      resources.each do |resource|
        return resource.href if resource.interface == interface_name
      end
      return nil
    end

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
