
class PatchUpdatesController < ApplicationController

   before_filter :login_required
   layout 'main'


  # GET /patch_updates
  # GET /patch_updates.xml
  def index
    set_permissions(controller_name)

    render :action => patch_list
  end

  # this was moved out of index to make it async
  # later
  def patch_list
    @patch_updates = PatchUpdate.find(:all)
    respond_to do |format|
      format.html { render :partial => 'patchlist' }
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
    ret_update = Hash.from_xml(response.body)    
    if ret_update["patch_update"]["error_id"] != 0
       flash[:error] = ret_update["patch_update"]["error_string"]
    else
       flash[:notice] = _("Patch has been installed.")
    end       
    redirect_to(patch_updates_url)
  end

end
