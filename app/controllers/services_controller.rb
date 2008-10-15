require 'service'

class ServicesController < ApplicationController
  before_filter :login_required
  layout 'main'

  def index
    @services = Service.find(:all, :from => '/services.xml')
  end
end
