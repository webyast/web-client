module YastModel
  # Resource model
  # Model for resources which provide each webyast rest-service to allow
  # introspect. for details see restdoc of webyast rest-service
  class Resource < ActiveResource::Base
    #Resources on target machine has always constant prefix to allow introspect
    self.prefix = '/'

    # helper to check if interfaces is available on target machine
    #
    # === params
    # args:: interfaces to check
    # returns:: true if all passed interface is available on logged machine
    # 
    # === usage
    #   res = YastModel::Resource.interfaces_available? :'org.opensuse.int1', :'org.opensuse.int2'
    def self.interfaces_available?(*args)
      self.site = YaST::ServiceResource::Session.site
      res = Resource.find :all
      args.each do |int|
        found = res.find{ |v| v.interface.to_sym == int.to_sym }
        return false if found.nil?
      end
      return true
    end
  end
end
