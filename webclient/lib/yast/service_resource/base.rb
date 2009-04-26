
module YaST
  module ServiceResource
    # Base class for REST resource proxies which talk
    # to a YaST REST service.
    #
    # Over ActiveResource::Base provides some conveniences like
    # using the url of the service in the current session
    #
    class Base < ActiveResource::Base

      def self.default_prefix
        "/yast"
      end
      
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
