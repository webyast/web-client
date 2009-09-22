# = ProxyLoader module
# Modules handles finding and loading proxy. It take care about pottential
# problems and redirect in problems to correct page.
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
# In case you don't want redirect (like in AJAX handlers)
#   include ProxyLoader
#   def index
#    @systemtime = load_proxy 'org.opensuse.yast.modules.yapi.time'
#    
#    unless @systemtime
#     erase_redirect_results
#     erase_render_results
#     #error handling
#     return false
#    end
#
#

module ProxyLoader
   #Finds proxy and find its result.
   #_fields_:: set @+permissions+ field to permissions of proxy
   #name:: Name of proxy
   #find_ard:: Argument for find call on proxy, nil is no argument (singleton resource)
   #+returns+:: Returns result of proxy.find or nil if something goes bad
   def load_proxy (name,find_arg = nil)
    proxy = YaST::ServiceResource.proxy_for(name)

    unless proxy
      logger.warn "Couldn't find proxy for #{name}"
      flash[:error] = "Cannot find service on target machine for #{name}."
      redirect_to root_path
      @permissions = nil
      return nil
    end

      @permissions = proxy.permissions
    
    ret = nil
    begin
      if find_arg
        ret = proxy.find find_arg
      else
        ret = proxy.find
      end
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      Rails.logger.warn e
      redirect_to root_path
    end

    return ret
  end
end
