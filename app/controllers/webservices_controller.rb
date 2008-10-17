class WebservicesController < ApplicationController
  # GET /webservices
  # GET /webservices.xml
  def index
    @webservices = Webservice.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @webservices }
    end
  end

  # GET /webservices/1
  # GET /webservices/1.xml
  def show
    @webservice = Webservice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @webservice }
    end
  end

  # GET /webservices/new
  # GET /webservices/new.xml
  def new
    @webservice = Webservice.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @webservice }
    end
  end

  # GET /webservices/1/edit
  def edit
    @webservice = Webservice.find(params[:id])
  end

  # POST /webservices
  # POST /webservices.xml
  def create
    @webservice = Webservice.new(params[:webservice])

    respond_to do |format|
      if @webservice.save
        flash[:notice] = 'Webservice was successfully created.'
        format.html { redirect_to(@webservice) }
        format.xml  { render :xml => @webservice, :status => :created, :location => @webservice }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @webservice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /webservices/1
  # PUT /webservices/1.xml
  def update
    @webservice = Webservice.find(params[:id])

    respond_to do |format|
      if @webservice.update_attributes(params[:webservice])
        flash[:notice] = 'Webservice was successfully updated.'
        format.html { redirect_to(@webservice) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @webservice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /webservices/1
  # DELETE /webservices/1.xml
  def destroy
    @webservice = Webservice.find(params[:id])
    @webservice.destroy

    respond_to do |format|
      format.html { redirect_to(webservices_url) }
      format.xml  { head :ok }
    end
  end
end
