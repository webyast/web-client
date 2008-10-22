include ApplicationHelper

class CommandsController < ApplicationController

  before_filter :login_required

  public

  def index
    id = params[:service_id]
    logger.debug "services/show #{id}"
    @service = Service.find(id, :from => '/services.xml')
    @commands = []
    @commands = @service.commands.split(",") unless @service==nil
    render
  end

  def update
    id = params[:service_id]
    logger.debug "services/show #{id}"
    @service = Service.find(id, :from => '/services.xml')
    @commands = []
    @commands = @service.commands.split(",") unless @service==nil
    flash[:notice] = 'Command has been run successfully'
    redirect_to :back, :action => "show" 
  end

end
