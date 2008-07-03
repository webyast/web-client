
require 'activeresource'

class Service < ActiveResource::Base
    self.site = 'http://localhost:3001'
end
