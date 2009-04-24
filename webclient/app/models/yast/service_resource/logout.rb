require 'yast/service_resource/base'

module YaST
  module ServiceResource
    # proxy for the service login
    class Logout < YaST::ServiceResource::Base
      self.collection_name = "logout"
      self.element_name = "hash"
    end
  end
end
