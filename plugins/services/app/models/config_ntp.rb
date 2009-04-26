require 'yast/service_resource/base'

class ConfigNtp< YaST::ServiceResource::Base
    self.collection_name = "services"
    self.element_name = "config_ntp"
end
