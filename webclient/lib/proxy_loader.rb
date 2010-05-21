#--
# Webyast Webservice framework
#
# Copyright (C) 2009, 2010 Novell, Inc. 
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation. 
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details. 
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++

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
   #find_arg:: Argument for find call on proxy, nil is no argument (singleton resource)
   #params:: Optional parameters passed to the REST backend
   #+returns+:: Returns result of proxy.find or nil if something goes bad
   def load_proxy (name,find_arg = nil, params = {})
    proxy = YaST::ServiceResource.proxy_for(name)

    unless proxy
      logger.warn "Couldn't find proxy for #{name}"
      flash[:error] = "Cannot find service on target machine for #{name}."
      redirect_to root_path
      @permissions = nil
      return nil
    end

    begin
      @permissions = proxy.permissions
    rescue Exception => e
      logger.error "Could not retrieve permissions"
      raise e
    end
    
    begin
      return proxy.find(find_arg, :params => params) if find_arg
      return proxy.find
    rescue ActiveResource::ClientError => e
      logger.error "#{e.message} when calling find"
      flash[:error] = YaST::ServiceResource.error(e)
      redirect_to root_path
    end
    nil
  end
end
