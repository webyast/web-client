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
         host = Webservice.new({"name"=>url, "desc"=>"via notwork scan"})
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

    createSessionTable = true
    if session[:controllers]!=nil && session[:controllers].size > 0
       #is at least one controller visible?
       session[:controllers].each do |key,controller|
          if controller.read_permission
             createSessionTable = false
             break
          end
       end 
    end
    if createSessionTable
       #insert at least a session controller
       modHash = Yast.new( )
       modHash.install_permission=false
       modHash.read_permission=true
       modHash.delete_permission=false
       modHash.new_permission=false
       modHash.write_permission=true
       modHash.description=""
       modHash.execute_permission=false
       modHash.path="session"
       modHash.visibleName="session"
       session[:controllers] = { "session"=>modHash }
    end
  end

  def create
    self.current_account, auth_token = Account.authenticate(params[:login], params[:password],
                                                            params[:hostname])
    if logged_in?
      session[:auth_token] = auth_token
      session[:user] = params[:login]
      session[:password] = params[:password]
      session[:host] = params[:hostname]
      
      #evaluate available modules
      @modules = Yast.find(:all)      
      moduleHash = {}
      @modules.each do |modHash|
        mo = modHash.path
        case mo
         when "services", "language", "users", "permissions"
            modHash.visibleName = mo
            moduleHash[mo] = modHash
         when "systemtime"
            modHash.visibleName = mo
            moduleHash["system_time"] = modHash
         when "patch_updates"
            modHash.visibleName = "patches"
            moduleHash[mo] = modHash
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
