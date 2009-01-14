# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
   layout 'main'

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # scan for hosts via slp
  def scan
    @hosts = []
    # make output parseable + terminate 
    services = `avahi-browse _yastws._tcp -t -p --no-db-lookup`
    
    # +;eth0;IPv4;YaST\032Webservice\032http\058\047\047aries\.suse\.de\0588080;_yastws._tcp;local
    
    services.each do |s|
      sp = s.split ";"
      next unless sp[0] == "+"
      name = sp[3]
      sp = name.split "\\"
      name = ""
      sp.each do |s|
	if s.length > 2
	  val = s[0,3].to_i
	  if val > 0
	    s = val.chr + (s[3..-1] || "")
	  end
	  name << s
	end
      end
      url = name.split(" ").pop || name

      if Webservice.find(:first, :conditions => "name = '#{url}'") == nil
         host = Webservice.new({"name"=>url, "desc"=>"via avahi scan"})
         @webservices << host
      end
    end
  end


  # render show.rhtml
  def show
    @webservices = Webservice.find(:all)
    scan #via avahi
    @user = session[:user] 
    @password = session[:password]
    @host = session[:host]
    if (@host == nil &&
        @webservices.size > 0)
       #take first
       @host = @webservices[0].name
    end
  end

  def create
    webservice = params[:webservice]
    self.current_account, auth_token = Account.authenticate(params[:login], params[:password],
                                                            webservice[:name])
    if logged_in?
      session[:auth_token] = auth_token
      session[:user] = params[:login]
      session[:password] = params[:password]
      session[:host] = webservice[:name]
      
      #evaluate available modules
      @modules = Yast.find(:all)      
      moduleHash = {}
      @modules.each do |modHash|
        mo = modHash.attributes["path"]
        case mo
         when "services", "language"
            moduleHash[mo] = mo
         when "systemtime"
            moduleHash["system_time"] = mo
         when "users"
            moduleHash[mo] = mo
            moduleHash["permissions"] = "permissions"
         when "patch_updates"
            moduleHash["patch_updates"] = "patches"
         else
            logger.debug "module #{mo} will not be shown"
        end
      end
      logger.debug "Available modules: #{moduleHash.inspect}"
      session[:controllers] = moduleHash

      redirect_back_or_default('/')
    else
      session[:user] = nil
      session[:password] = nil
      session[:host] = nil
      session[:controllers] = nil
      show # getting hosts again
      render :action => 'show'
    end
  end

  def destroy
     session[:user] = nil
     session[:password] = nil
     session[:host] = nil
     session[:controllers] = nil
     if logged_in?
        ret = Logout.create()
        if (ret and ret.attributes["logout"])
           puts "Logout: #{ret.attributes["logout"]}"
        else
           puts "Logout: Error"
        end
        self.current_account.forget_me 
        session[:auth_token] = nil
     end
     
     cookies.delete :auth_token
     reset_session
     flash[:notice] = "You have been logged out."
     redirect_back_or_default('/')
  end
end
