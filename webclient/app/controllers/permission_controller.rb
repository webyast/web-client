class PermissionController < ApplicationController
  layout "main"
  require 'pp'
  def display
    if request.post?
      pp params
#      flash[:notice] = params[:thing_name]
    end
  end
end
