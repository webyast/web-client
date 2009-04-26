require 'yast/service_resource/base'

class Service < YaST::ServiceResource::Base
  attr_accessor :commandList
end
