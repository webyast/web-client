require 'yast/service_resource/base'

class Checkpermission < YaST::ServiceResource::Base
    self.collection_name = "checkpermission"
    self.element_name = "hash"
end
