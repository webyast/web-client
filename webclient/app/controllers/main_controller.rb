class MainController < ApplicationController
  def index
    redirect_to :controller => "session", :action => "index"
  end
end
