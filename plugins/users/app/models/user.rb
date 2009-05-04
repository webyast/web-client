require 'yast/service_resource'

class User < YaST::ServiceResource::Base
  attr_accessor :type,
                :grp_string
  #self.prefix = "#{default_prefix}"
end
