require 'yast/service_resource'

class LanguageController < ApplicationController
  before_filter :login_required
  layout 'main'

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_language"  # textdomain, options(:charset, :content_type)


  def index
    set_permissions(controller_name)
    proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.modules.yapi.language')
    @permissions = proxy.permissions
    begin
      @language = proxy.find
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
    end

    @valid = []
    
    if @language
      @language.available.each do  |avail|
        @valid << avail.name
        if avail.id.size>0 && avail.id == @language.current
          @current = avail.name
        end        
      end
      @rootlocale=@language.rootlocale
      @utf8 = @language.utf8
    end
  end

  def commit_language
     proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.modules.yapi.language')
     proxy.timeout = 120
     @permissions = proxy.permissions
     begin
       lang = proxy.find
       rescue ActiveResource::ClientError => e
         flash[:error] = YaST::ServiceResource.error(e)
     end

     if lang

       lang.available.each do  |avail|
         if params[:first_language]==avail.name
           lang.current = avail.id
           break
         end
       end

       lang.available = [] #not needed anymore
       if params[:utf8] && params[:utf8]=="true"
        lang.utf8 = "true"
       else
        lang.utf8 = "false"
       end
       lang.rootlocale = params[:rootlocale]
       
       response = true
       begin
         response = lang.save
         rescue ActiveResource::ClientError => e
           flash[:error] = YaST::ServiceResource.error(e)
           response = false
       end
       flash[:notice] = _("Settings have been written.") if response
     end
     redirect_to :action => :index 
  end

end
