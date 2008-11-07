class LanguageController < ApplicationController
  before_filter :login_required
  layout 'main'
  def index
    @language = Language.find(:one, :from => '/language.xml')
    if params[:last_error] && params[:last_error] != 0
       @language.error_id = params[:last_error]
       if params[:last_error_string]
          @language.error_string = params[:last_error_string]
       end
    end
    @valid = []
    @secondLanguages = {}
    splitSecondLanguages = []
    if @language.secondLanguages
       splitSecondLanguages = @language.secondLanguages.split(",")
    end
    @valid = @language.available.split("\n")
    @valid::each do |l|   
       dummy = l.split(" ")
       if dummy.size>0 && dummy[0]==@language.firstLanguage
          @language.firstLanguage = l
       end
       checked = ""
       splitSecondLanguages::each do |s|
          if dummy.size>0 && dummy[0]==s
             checked = "checked"
          end
       end
       @secondLanguages[l] = checked
    end
  end

  def commit_language
    lang = Language.find(:one, :from => '/language.xml')
    dummy = params[:firstLanguage].split(" ")
    lang.firstLanguage = dummy[0] #take index only
    lang.available = "" #not needed anymore
    lang.secondLanguages = ""
    counter = 0
    params::each do |name,value|   
       if value=="LanguageSet"
          if counter==0
             lang.secondLanguages = name
          else
             lang.secondLanguages = lang.secondLanguages + "," + name
          end
          counter = counter+1
       end
    end
    lang.save
    if lang.error_id != 0
       redirect_to :action => :index, :last_error_string =>lang.error_string, :last_error =>lang.error_id 
    else
       redirect_to :action => :index 
    end
  end

end
