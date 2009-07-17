require 'uri'

class HostsController < ApplicationController
  layout 'main'

  #
  # GET /hosts
  # Display list of hosts for user to choose (or add)
  # params :error, :hostid, set if previously choosen host is wrong
  #
  def index
    begin
      @hosts = Host.find(:all)
    rescue Exception => e
      logger.error e.to_s
      # show nice error screen and remind to "rake db:migrate"
      redirect_to "/migration_missing"
    end
    
    # error is set if session couldn't be established and user has to re-choose the host
    # flash[] doesn't survive redirects across controllers :-(
    error = params[:error]
    if error == "econnrefused"
      host = Host.find(params[:hostid]) rescue nil
      flash[:error] = _("Can't connect to host #{host.name}.") if host
      flash[:warning] = _("Make sure the host is up and that the YaST web service is running.")
    elsif error == "nohostid"
      flash[:notice] = _("Please select a host to connect to.")
    end
  end

  # GET /hosts/show/1
  def show
    @host = Host.find(params[:id])
  end

  # GET /hosts/new
  def new
    @host = Host.new
  end

  # GET /hosts/1/edit
  def edit
    @host = Host.find(params[:id])
  end

  # POST /hosts
  # the :host parameter is a hash with all values
  #  see the form in app/views/hosts/new.html.erb 
  def create
    @host = Host.new(params[:host])

    if @host.save
      flash[:notice] = 'Host was successfully created.'
      redirect_to :action => 'index'
    else
      redirect_to :action => 'new'
    end
  end

  # PUT /hosts/1
  def update
    host = Host.find(params[:id])

    if host.update_attributes(params[:host])
      flash[:notice] = 'Host updated.'
      redirect_to :action => 'index'
    else
      redirect_to :action => 'edit'
    end
  end

  # DELETE /hosts/1
  def destroy
    host = Host.find(params[:id])
    if host
	flash[:notice] = 'Host removed.'
	host.destroy
    end
    redirect_to :action => 'index'
  end

  def validate_uri
    logger.error params[:host][:url]
    uri = URI.parse(params[:host][:url]) rescue nil
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      render :text => 'false'
      return
    end
    render :text => 'true'
  end
end
