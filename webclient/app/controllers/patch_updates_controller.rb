
class PatchUpdatesController < ApplicationController

   before_filter :login_required
   layout 'main'


  # GET /patch_updates
  # GET /patch_updates.xml
  def index
    @patch_updates = PatchUpdate.find(:all)
    if params[:last_error] && params[:last_error] != 0
       update = PatchUpdate.new( :error_id =>params[:last_error], 
                                 :error_string=>params[:last_error_string] )
       @patch_updates << update
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @patch_updates }
      format.json { render :json => @patch_updates.to_json }
    end
  end

  # POST /patch_updates/1
  # POST /patch_updates/1.xml
  def install
    @update = PatchUpdate.new( :id => "install",
                               :error_id =>0, 
                               :error_string=>nil )
    response = @update.post(params[:id], {}, @update.to_xml)
    retUpdate = Hash.from_xml(response.body)    
    if retUpdate["patch_update"]["error_id"] != 0
       redirect_to(patch_updates_url, 
                   :last_error_string =>retUpdate["patch_update"]["error_string"], 
                   :last_error =>retUpdate["patch_update"]["error_id"])
    else
       redirect_to(patch_updates_url)
    end
  end

end
