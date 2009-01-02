class PermissionController < ApplicationController
  layout "main"

  def constructPermissions ( pattern, level, granted, output)
     
  end

  def search
    path = "/users/#{params[:user].rstrip}/permissions.xml"
    @permissions = Permission.find(:all, :from => path)
    logger.debug "permissions of user #{params[:user].rstrip}: #{@permissions.inspect}"
    render :action => "index" 
  end

  def index
  end
end
