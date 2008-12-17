class MainController < ApplicationController
  def index
    redirect_to :controller => "hosts", :action => "list"
  end
end
