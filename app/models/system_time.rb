class SystemTime < ActiveResource::Base
    self.site = "http://localhost:3001"
    self.collection_name = "system"
end
