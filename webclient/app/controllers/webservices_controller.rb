class WebservicesController < ApplicationController
  layout 'main'

  # GET /webservices
  def index
    begin
      @webservices = Webservice.find(:all)
    rescue
      redirect_to "/migrate"
    end
  end

  # GET /webservices/show/1
  def show
    @webservice = Webservice.find(params[:id])
  end

  # GET /webservices/new
  def new
    @webservice = Webservice.new
  end

  # GET /webservices/1/edit
  def edit
    @webservice = Webservice.find(params[:id])
  end

  # POST /webservices
  def create
    @webservice = Webservice.new(params[:webservice])

    if @webservice.save
      flash[:notice] = 'Webservice was successfully created.'
      redirect_to webservices_url
    else
      redirect_to new_webservice_url
    end
  end

  # PUT /webservices/1
  def update
    @webservice = Webservice.find(params[:id])

    if @webservice.update_attributes(params[:webservice])
      flash[:notice] = 'Webservice was successfully updated.'
      redirect_to webservices_url
    else
      redirect_to edit_webservice_url
    end
  end

  # DELETE /webservices/1
  def destroy
    @webservice = Webservice.find(params[:id])
    @webservice.destroy

    redirect_to webservices_url
  end
end
