#
# Main
#
# This is the default controller for webclient
#
# It will check if a session is established
# and redirect to ControlPanel.index or Session.new
#

class MainController < ApplicationController
  def index
    
# FIXME: hostid should be configurable
    redirect_to(logged_in? ?
		{ :controller => "controlpanel", :action => "index" } :
		{ :controller => "session", :action => "new", :hostid => "localhost" })
  end

  # POST /select_language
  # setting language for translations
  def select_language
    respond_to do |format|
      format.html { render :partial => "select_language" }
    end    
  end


end
