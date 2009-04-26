require 'yast/service_resource/base'

class SystemTime < YaST::ServiceResource::Base
    self.collection_name = "systemtime"
    self.element_name = "systemtime"
end
