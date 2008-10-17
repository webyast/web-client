class Login < MyActiveResource
    self.collection_name = "login"
    self.element_name = "hash"

    def initServiceUrl (url)
       ActiveResource::Base.site = url
    end

    def setWebServiceAuth (auth_token)
       ActiveResource::Base.password = auth_token
       ActiveResource::Base.user = ""
    end

end
