require 'yast/service_resource'

class Session < YaST::ServiceResource
    self.collection_name = "session"
    self.element_name = "hash"
end
