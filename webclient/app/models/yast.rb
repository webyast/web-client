require 'yast/service_resource'

class Yast < YaST::ServiceResource::Base
  self.collection_name = "yast"
  attr_accessor :visible_name
end
