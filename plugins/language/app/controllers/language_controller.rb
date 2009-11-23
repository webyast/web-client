require 'yast/service_resource'

# = Language controller
# Provides all functionality, that handles locale management module.
# The most functionality around language handling is in rest-service and this
# controller just provide handling of different exceptions and UI features.

class LanguageController < ApplicationController
  before_filter :login_required
  layout 'main'
#include ProxyLoader
  include LangHelper

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_language"  # textdomain, options(:charset, :content_type)

  # Index handler. Loads information from backend and if success all required
  # fields is filled. In case of errors redirect to help page, main page or just
  # show flash with partial problem.
  def index
    return #no backend stuff is needed in appliance
    language = load_proxy 'org.opensuse.yast.modules.yapi.language'
    
    unless language
      return false
    end

    unless@permissions[:read]
      flash[:warning] = _("No permissions for language module")
      redirect_to root_path
      return false
    end

    @valid = language.available.collect { |item| item.name } || []
    @valid = @valid.sort_by { |item| item.parameterize }
    cur = language.available.find { |avail| avail.id.size>0 && avail.id == language.current }
    @current = cur ? cur.name : ""
    @rootlocale=language.rootlocale
    @utf8 = language.utf8
    
  end

  # Update handler. Sets to backend new language settins. If
  # everything goes fine show confirmation message, otherwise show some error.
  def update
    cookies["lang"] = params[:webyast_language]
    set_locale params[:webyast_language]
    redirect_success
    return #do nothing for update
    lang = load_proxy 'org.opensuse.yast.modules.yapi.language'

    if lang
      cur = lang.available.find { |avail| params[:first_language]==avail.name }
      lang.current = cur.id if cur

      lang.available = [] #not needed anymore
      lang.utf8 = (params[:utf8] && params[:utf8]=="true") ? "true" : "false"
      lang.rootlocale = params[:rootlocale]
              
      begin
        lang.save
        flash[:notice] = _("Language settings have been written.")
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
      end
    end
    redirect_success
  end

end
