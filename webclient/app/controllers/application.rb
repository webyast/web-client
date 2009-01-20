# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout 'main'

  include AuthenticatedSystem

  helper :all # include all helpers, all the time
  
  def initialize
    super
  end

  def setPermissions(controllerName)
    if (session[:controllers] &&
        session[:controllers][controllerName])
       if session[:controllers][controllerName].write_permission
          @writePermission = nil
       else
          @writePermission = "disabled"
       end 
       if session[:controllers][controllerName].read_permission
          @readPermission = nil
       else
          @readPermission = "disabled"
       end 
       if session[:controllers][controllerName].delete_permission
          @deletePermission = nil
       else
          @deletePermission = "disabled"
       end 
       if session[:controllers][controllerName].new_permission
          @newPermission = nil
       else
          @newPermission = "disabled"
       end 
       if session[:controllers][controllerName].execute_permission
          @executePermission = nil
       else
          @executePermission = "disabled"
       end 
    else
       @executePermission = "disabled"
       @newPermission = "disabled"
       @deletePermission = "disabled"
       @readPermission = "disabled"
       @writePermission = "disabled"
    end
  end


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'b1aeb693a1ee49ab70c6b6bf514963a3'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password
end
