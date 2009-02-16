# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout 'main'

  include AuthenticatedSystem

  helper :all # include all helpers, all the time
  
  def initialize
    super
  end

  def set_permissions(controller_name)
    if (session[:controllers] &&
        session[:controllers][controller_name])
       if session[:controllers][controller_name].write_permission
          @write_permission = nil
       else
          @write_permission = "disabled"
       end 
       if session[:controllers][controller_name].read_permission
          @read_permission = nil
       else
          @read_permission = "disabled"
       end 
       if session[:controllers][controller_name].delete_permission
          @delete_permission = nil
       else
          @delete_permission = "disabled"
       end 
       if session[:controllers][controller_name].new_permission
          @new_permission = nil
       else
          @new_permission = "disabled"
       end 
       if session[:controllers][controller_name].execute_permission
          @execute_permission = nil
       else
          @execute_permission = "disabled"
       end 
       if session[:controllers][controller_name].install_permission
          @install_permission = nil
       else
          @install_permission = "disabled"
       end 
    else
       @execute_permission = "disabled"
       @new_permission = "disabled"
       @delete_permission = "disabled"
       @read_permission = "disabled"
       @write_permission = "disabled"
       @install_permission = "disabled"
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
