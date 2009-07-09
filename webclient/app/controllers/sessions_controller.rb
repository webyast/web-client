require 'yast/service_resource/login'
require 'yast/service_resource/logout'

# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  layout 'main'

  # make sure logout only happens if we are logged in
  # and the inverse
  #before_filter :ensure_login, :only => :destroy
  #before_filter :ensure_logout, :only => [:new, :create]
  
  def index
    # only used to display the flash message
  end

  # shows the current session
  def show
  end

  #
  # Start new session
  #
  def new
    @hostname = params[:hostname]
    
    # we can't create session if we are logged in
    if logged_in?
      redirect_to session_path
      return
    end

    # if the hostname is not set, go to the webservices controller
    # to pickup a service
    if not params.has_key?(:hostname)
      flash[:notice] = _("Please select a host to connect to.") unless flash[:notice]
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
        logger.warn e.to_s
        logger.info e.backtrace.join("\n")
        flash[:warning] = _("Error when trying to login: #{e.to_s}")
        redirect_to new_session_path(:hostname => params[:hostname])
        #redirect_to :action => :login, :hostname => params[:hostname]
        return
      end
    
      if logged_in?
        session[:auth_token] = auth_token
        session[:user] = params[:login]
        session[:host] = params[:hostname]

        # evaluate available service resources here or not?
        # @modules = Yast.find(:all)
  
        @short_host_name = session[:host]
        if @short_host_name.index("://") != nil
          @short_host_name = @short_host_name[@short_host_name.index("://")+3, @short_host_name.length-1] #extract "http(s)://"
        end

        # success, go to the main menu
        logger.info "Login success."
        redirect_to "/"
        return
      else
        session[:user] = nil
        session[:host] = nil
        #show # getting hosts again
        flash[:warning] = _("Login incorrect. Check your username and password.")
        redirect_to new_session_path(:hostname => params[:hostname])
        return
      end
    end
  end

  def destroy
    # remove session data
    [:user, :host].each do |k|
      session[k] = nil
    end

     if logged_in?
       ret = YaST::ServiceResource::Logout.create rescue nil
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
     flash[:notice] = _("You have been logged out.") unless flash[:notice]
     redirect_to new_session_path
     return
  end
end
