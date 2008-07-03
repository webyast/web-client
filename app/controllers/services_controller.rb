require 'service'

class ServicesController < ApplicationController
  layout 'main'

  def index
    @services = Service.find(:all, :from => '/services.xml')
  end
end
