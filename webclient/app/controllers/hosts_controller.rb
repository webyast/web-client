class HostsController < ApplicationController
  layout 'main'

  # GET /hosts
  def index
    begin
      @hosts = Host.find(:all)
    rescue
      redirect_to "/migrate"
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
end
