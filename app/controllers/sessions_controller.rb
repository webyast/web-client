# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new
  end

  def create
    self.current_account, auth_token = Account.authenticate(params[:login], params[:password])
    if logged_in?
      session[:auth_token] = auth_token
      if params[:remember_me] == "1"
        current_account.remember_me unless current_account.remember_token?
        cookies[:auth_token] = { :value => self.current_account.remember_token , :expires => self.current_account.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
    else
      render :action => 'new'
    end
  end

  def destroy
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
