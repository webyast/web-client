
class SystemController < ApplicationController
    before_filter :login_required

    def initialize
	@sys = System.new rescue nil
	@host = Host.find(session[:host]) rescue 'computer'
    end

    def reboot
	if request.put?
	    begin
		if !@sys.nil? and @sys.reboot
		    flash[:message] = "Rebooting #{@host}..."
		else
		    flash[:error] = "Cannot reboot #{@host}!"
		end
	    rescue Exception => e
		flash[:error] = "Cannot reboot #{@host}!"
	    end
	else
	    flash[:error] = 'Reboot request is accepted only via PUT method!'
	end

	redirect_to :controller => :controlpanel, :action => :index
    end

    def shutdown
	if request.put?
	    begin
		if !@sys.nil? and @sys.shutdown
		    flash[:message] = "Shuting down #{@host}..."
		else
		    flash[:error] = "Cannot shutdown #{@host}!"
		end
	    rescue Exception => e
		flash[:error] = "Cannot shutdown #{@host}!"
	    end
	else
	    flash[:error] = 'Shutdown request is accepted only via PUT method!'
	end

	redirect_to :controller => :controlpanel, :action => :index
    end
end

# vim: ft=ruby
