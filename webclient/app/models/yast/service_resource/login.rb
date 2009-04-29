require 'yast/service_resource'

module YaST
  module ServiceResource
    # proxy for the service login
    class Login < YaST::ServiceResource::Base
      self.collection_name = "login"
      self.element_name = "hash"
    end
  end
end
