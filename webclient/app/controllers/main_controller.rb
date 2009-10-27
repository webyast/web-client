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
    redirect_to(logged_in? ?
		{ :controller => "controlpanel", :action => "index" } :
		{ :controller => "session", :action => "new", :hostid => 1 })
  end
end
