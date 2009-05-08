require 'yast/service_resource'

class LanguageController < ApplicationController
  before_filter :login_required
  layout 'main'

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_language"  # textdomain, options(:charset, :content_type)


  def index
    set_permissions(controller_name)
    proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.language')
    @permissions = proxy.permissions
    
    @language = proxy.find

    @second_languages = {}
    @valid = []

    @language.available.each do  |avail|
       @valid << avail.name
       if avail.id.size>0 && avail.id==@language.first_language
          @language.first_language = avail.name
       end
       checked = ""
       @language.second_languages::each do |s|
          if avail.id.size>0 && avail.id==s.id
             checked = "checked"
          end
       end
       @second_languages[avail.name.tr_s(" ", "_")] = checked
    end
  end

  def commit_language
     proxy = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.language')
     @permissions = proxy.permissions
     lang = proxy.find

     lang = Language.find(:one, :from => '/language.xml')
     hash_avail = {}
     lang.available.each do  |avail|
        hash_avail[avail.name.tr_s(" ", "_")] = avail.id
     end

     lang.first_language = hash_avail[params[:first_language].tr_s(" ", "_")]
     lang.available = [] #not needed anymore
     lang.second_languages = []
     params::each do |name,value|   
       if value=="LanguageSet"
          l = Language::SecondLanguage.new( :id => hash_avail[name] )
          lang.second_languages << l
       end
     end
     lang.save
     if lang.error_id != 0
        flash[:error] = lang.error_string
     else
        flash[:notice] = _("Settings have been written.")
     end       
     redirect_to :action => :index 
  end

end
