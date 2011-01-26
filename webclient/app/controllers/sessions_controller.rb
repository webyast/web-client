#--
# Webyast Webclient framework
#
# Copyright (C) 2009, 2010 Novell, Inc. 
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation. 
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details. 
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++

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
    redirect_to "/"
  end

  def show
    redirect_to "/"
  end

  #
  # Start new session
  #  render login screen
  #
  def new
    # Set @host to display info at login screen
    @host = Host.find_by_id_or_name(params[:hostid])

    # if the hostname is not set, go to the host controller
    # to pickup a service
    unless @host
      redirect_to :controller => 'hosts', :action => 'index', :error => "nohostid"
      return
    end

    # render login screen, asking for username/password
  end
  
  # create session
  #  this is called from login form and expects to have username and password set
  #
  # if the create action is called without the hostname
  # it will show the login form # XXX tom: probably needs reset_session to avoid session fixation etc.
  def create
    host = Host.find_by_id_or_name(params[:hostid])
    logger.debug "Host(#{params[:hostid]}): #{host.inspect}"
    # if the user or password is not there, then render the login form
    if host.nil?
      flash[:warning] = _("You need to specify the host")
      redirect_to :action => "new"
    elsif params[:login].blank?
      flash[:warning] = _("No login specified")
      redirect_to :action => "new", :hostid => host.id
    elsif params[:password].blank?
      flash[:warning] = _("No password specified")
      redirect_to :action => "new", :login => params[:login], :hostid => host.id
    else
      # otherwise, we have all the data, try to login
      begin
        self.current_account, auth_token, expires_date = Account.authenticate(params[:login], 
                                                            params[:password],
                                                            host.url)
	# error handling when login to the service is pretty
        # important to get meaningful error messages to the user
      rescue Errno::ECONNREFUSED => e
        redirect_to :controller => "hosts", :action => "index", :hostid => host.id, :error => "econnrefused"
        return
      rescue SocketError => e
        redirect_to :controller => "hosts", :action => "index", :hostid => host.id, :error => "ecantresolve"
        return
      rescue Account::BlockedService => e
        session[:user] = session[:host] = nil
        #show warning that user %s cannot log to host. He can try it at first at %s (time of target machine)
        flash[:warning] = _("Host has blocked user %s. It cannot login until  %s") % [params[:login], e.time.to_s]
        redirect_to :action => "new", :hostid => host.id
        return
      end
      
      # Now check if the authentication was successful
    
      if logged_in?
        session[:auth_token] = auth_token
        session[:user] = params[:login]
        session[:host] = host.id
	session[:expires] = expires_date

        #reset resource cache after login to refresh permissions and modules (bnc#621579)
        ResourceCache.instance.reset_cache params[:login], host.url

        # evaluate available service resources here or not?
        # @modules = Yast.find(:all)
  
        @short_host_name = host.name

        # success, go to the main controller
        logger.info "Login success."
        redirect_back_or_default("/")
      else
        session[:user] = session[:host] = nil
        #show # getting hosts again
        flash[:warning] = _("Login incorrect. Check your username and password.")
        redirect_to :action => "new", :hostid => host.id
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

    # reset_session clears all flash messages, make a backup before the call
    flash_backup = flash

    reset_session # RORSCAN_ITL

    # restore the values from backup
    flash.replace(flash_backup)

    flash[:notice] = _("You have been logged out.") unless flash[:notice]
    #FIXME redirect to hosts if we are not on appliance
    redirect_to :controller => "session", :action => "new", :hostid => "localhost"
  end
end
