require 'activeresource'

class SystemTime < ActiveResource::Base
    self.site = "http://192.168.1.84:3000/system/time/system_time"
end

