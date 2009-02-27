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
         host = Webservice.new({"name"=>url, "desc"=>"via network scan"})
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

    create_session_table = true
    if session[:controllers]!=nil && session[:controllers].size > 0
       #is at least one controller visible?
       session[:controllers].each do |key,controller|
          if controller.read_permission
             create_session_table = false
             break
          end
       end 
    end
    if create_session_table
       #insert at least a session controller
       mod_hash = Yast.new( )
       mod_hash.install_permission=false
       mod_hash.read_permission=true
       mod_hash.delete_permission=false
       mod_hash.new_permission=false
       mod_hash.write_permission=true
       mod_hash.description=""
       mod_hash.execute_permission=false
       mod_hash.path="session"
       session[:controllers] = { "session"=>mod_hash }
    end
  end

  def index
    show
    render :template=>"sessions/show"
  end

  def create
    begin
      self.current_account, auth_token = Account.authenticate(params[:login], 
                                                            params[:password],
                                                            params[:hostname])
    rescue
    end
    
    if logged_in?
      session[:auth_token] = auth_token
      session[:user] = params[:login]
      session[:password] = params[:password]
      session[:host] = params[:hostname]

      #evaluate available modules
      @modules = Yast.find(:all)      
      module_hash = {}
      @modules.each do |mod_hash|
        mo = mod_hash.path
        case mo
         when "services", "language", "users", "permissions", "patch_updates"
            module_hash[mo] = mod_hash
         when "systemtime"
            module_hash["system_time"] = mod_hash
         else
            logger.debug "module #{mo} will not be shown"
        end
      end
      logger.debug "Available modules: #{module_hash.inspect}"
      session[:controllers] = module_hash

      @short_host_name = session[:host]
      if @short_host_name.index("://") != nil
         @short_host_name = @short_host_name[@short_host_name.index("://")+3, @short_host_name.length-1] #extract "http(s)://"
      end

      render :partial =>"login_succeeded"
    else
      session[:user] = nil
      session[:password] = nil
      session[:host] = nil
      session[:controllers] = nil
      show # getting hosts again
      render :partial =>"login_failed"
    end
  end


  def updateMenu
      render :partial => "controllers"
  end

  def updateLogout
      if session[:user]
    	 render :partial => "logout"
      else
    	 render :nothing => true
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
           logger.debug "Logout: #{ret.attributes["logout"]}"
        else
           logger.debug "Logout: Error"
        end
        self.current_account.forget_me 
        session[:auth_token] = nil
     end
     
     cookies.delete :auth_token
     reset_session
     flash[:notice] = _("You have been logged out.")
     redirect_back_or_default('/')
  end
end
