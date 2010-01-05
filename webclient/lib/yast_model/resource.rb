module YastModel
  # Resource model
  # Model for resources which provide each webyast rest-service to allow
  # introspect. for details see restdoc of webyast rest-service
  class Resource < ActiveResource::Base
    self.prefix = '/'
    #Resources on target machine has always constant prefix to allow introspect
  end
end
