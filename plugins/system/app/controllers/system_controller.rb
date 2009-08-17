
class SystemController < ApplicationController
    before_filter :login_required

    include GetText

    def initialize
	@sys = System.new rescue nil
    end

    def reboot
	if request.put?
	    begin
		if !@sys.nil? and @sys.reboot
		    flash[:message] = _("Rebooting the machine...")
		else
		    flash[:error] = _("Cannot reboot the machine!")
		end
	    rescue Exception => e
		flash[:error] = _("Cannot reboot the machine!")
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
		    flash[:message] = _("Shuting down the machine...")
		else
		    flash[:error] = _("Cannot shutdown the machine!")
		end
	    rescue Exception => e
		flash[:error] = _("Cannot shutdown the machine!")
	    end
	else
	    flash[:error] = 'Shutdown request is accepted only via PUT method!'
	end

	redirect_to :controller => :controlpanel, :action => :index
    end
end

# vim: ft=ruby
