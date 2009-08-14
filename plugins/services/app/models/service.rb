require 'yast/service_resource'

class Service < YaST::ServiceResource::Base
  attr_accessor :commandList
end
