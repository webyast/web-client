# = ProxyLoader module
# Modules handles finding and loading proxy. It take care about pottential problems
# == requirements
# Use ExceptionLogger module to it run. Intended to be used in Controller.
# == Usage
# Include module in controller and use method load_proxy.
# 
#   include ProxyLoader
#   def index
#    @systemtime = load_proxy 'org.opensuse.yast.modules.yapi.time'
#    
#    unless @systemtime
#     return false
#    end
#    ...
#

module ProxyLoader
  include ExceptionLogger
   #Finds proxy and find its result.
   #_fields_:: set @+permissions+ field to permissions of proxy
   #name:: Name of proxy
   #+returns+:: Returns result of proxy.find or nil if something goes bad
   def load_proxy (name)
    proxy = YaST::ServiceResource.proxy_for(name)

    unless proxy
      logger.warn "Couldn't find proxy for #{name}"
      flash[:error] = "Cannot find service on target machine for #{name}."
      @permissions = nil
      return nil
    end

    @permissions = proxy.permissions

    ret = nil
    begin
      ret = proxy.find
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      log_exception e
    rescue Exception => e
      flash[:error] = e.message
      log_exception e
    end

    return ret
  end
end
