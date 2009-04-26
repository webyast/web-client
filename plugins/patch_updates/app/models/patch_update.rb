require 'yast/service_resource/base'

class PatchUpdate < YaST::ServiceResource::Base
  self.timeout = 120
end
