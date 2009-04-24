require 'yast/service_resource/login'
require 'yast/service_resource/logout'

# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  layout 'main'

  # make sure logout only happens if we are logged in
  # and the inverse
  #before_filter :ensure_login, :only => :destroy
  #before_filter :ensure_logout, :only => [:new, :create]
  
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  # helper scan for hosts via slp
  # may be move out?
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

  def index
    # only used to display the flash message
  end

  # shows the current session
  # for that we reuse the _currentsession
  # partial
  def show
    render :partial => 'current_session'
  end

  # this was originally used to cache the list
  # of "controllers in the server"
  # but we will figure other way to to this
  def show_FIXME
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
       #mod_hash = Yast.new( )
       #mod_hash.install_permission=false
       #mod_hash.read_permission=true
       #mod_hash.delete_permission=false
       #mod_hash.new_permission=false
       #mod_hash.write_permission=true
       #mod_hash.description=""
       #mod_hash.execute_permission=false
       #mod_hash.path="session"
       #session[:controllers] = { "session"=>mod_hash }
    end
  end

  def new
    @hostname = params[:hostname]
    
    # we can't create session if we are logged in
    if logged_in?
      redirect_to session_path
    end

    # if the hostname is not set, go to the webservices controller
    # to pickup a service
    if not params.has_key?(:hostname)
      flash[:notice] = _("Please select a host to connect to.")
      redirect_to :controller => 'webservices'
      return
    end
  end
  
  # if the create action is called without the hostname
  # it will show the login form
  def create
    # if the user or password is not there, then render the login form
    if not params.has_key?(:hostname) or params[:hostname].empty?
      flash[:warning] = _("You need to specify the hostname")
      redirect_to new_session_path(:hostname => params[:hostname])
      return
    elsif not params.has_key?(:password) or params[:password].empty?
      flash[:warning] = _("No password specified")
      redirect_to new_session_path(:hostname => params[:hostname])
      return
    else
      # otherwise, we have all the data, try to login
      begin
        self.current_account, auth_token = Account.authenticate(params[:login], 
                                                            params[:password],
                                                            params[:hostname])
        # error handling when loggin in to the service is pretty
        # important to get meanful error messages to the user
      rescue Errno::ECONNREFUSED => e
        flash[:warning] = _("Can't connect to host at #{params[:hostname]}, make sure the host is up and that the YaST web service is running.")
        #redirect_to :action => :login, :hostname => params[:hostname]
        redirect_to new_session_path(:hostname => params[:hostname])
        return
      rescue Exception => e
        flash[:warning] = _("Error when trying to login: #{e.to_s}")
        redirect_to new_session_path(:hostname => params[:hostname])
        #redirect_to :action => :login, :hostname => params[:hostname]
        return
      end
    
      if logged_in?
        session[:auth_token] = auth_token
        session[:user] = params[:login]
        session[:password] = params[:password]
        session[:host] = params[:hostname]

        # evaluate available service resources here or not?
        # @modules = Yast.find(:all)
  
        @short_host_name = session[:host]
        if @short_host_name.index("://") != nil
          @short_host_name = @short_host_name[@short_host_name.index("://")+3, @short_host_name.length-1] #extract "http(s)://"
        end

        # success, go to the main menu
        #logger.info "Login success. #{session[:controllers].size} service resources"
        logger.info "Login success."
        redirect_to "/"
        return
        #render :partial =>"login_succeeded"
      else
        session[:user] = nil
        session[:password] = nil
        session[:host] = nil
        session[:controllers] = nil
        #show # getting hosts again
        flash[:warning] = _("Login incorrect. Check your username and password.")
        redirect_to new_session_path(:hostname => params[:hostname])
        return
      end
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
    # remove session data
    [:user, :password, :host, :controllers].each do |k|
      session[k] = nil
    end

     if logged_in?
       ret = YaST::ServiceResource::Logout.create
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
     redirect_to new_session_path
     return
  end
end
