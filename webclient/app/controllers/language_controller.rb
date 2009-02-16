class LanguageController < ApplicationController
  before_filter :login_required
  layout 'main'
  def index
    set_permissions(controller_name)

    @language = Language.find(:one, :from => '/language.xml')
    @valid = []
    @second_languages = {}
    split_second_languages = []
    if @language.second_languages
       split_second_languages = @language.second_languages.split(",")
    end
    @valid = @language.available.split("\n")
    @valid::each do |l|   
       dummy = l.split(" ")
       if dummy.size>0 && dummy[0]==@language.first_language
          @language.first_language = l
       end
       checked = ""
       split_second_languages::each do |s|
          if dummy.size>0 && dummy[0]==s
             checked = "checked"
          end
       end
       @second_languages[l] = checked
    end
  end

  def commit_language
    lang = Language.find(:one, :from => '/language.xml')
    dummy = params[:first_language].split(" ")
    lang.first_language = dummy[0] #take index only
    lang.available = "" #not needed anymore
    lang.second_languages = ""
    counter = 0
    params::each do |name,value|   
       if value=="LanguageSet"
          if counter==0
             lang.second_languages = name
          else
             lang.second_languages = lang.second_languages + "," + name
          end
          counter = counter+1
       end
    end
    lang.save
    if lang.error_id != 0
       flash[:error] = lang.error_string
    else
       flash[:notice] = "Settings have been written."
    end       
    redirect_to :action => :index 
  end

end
