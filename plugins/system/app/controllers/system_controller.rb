#--
# Copyright (c) 2009-2010 Novell, Inc.
# 
# All Rights Reserved.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
# 
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#++

class SystemController < ApplicationController
    before_filter :login_required

    # Initialize GetText and Content-Type.
    init_gettext "yast_webclient_system"  # textdomain, options(:charset, :content_type)

    def initialize
	@sys = System.new rescue nil
    end

    def reboot
	if request.put?
	    begin
		if !@sys.nil? and @sys.reboot
		    flash[:message] = _("Rebooting the machine...")
		    # logout from the service, reboot is in progress
		    redirect_to(logout_path) and return
		else
		    flash[:error] = _("Cannot reboot the machine!")
		end
	    rescue ActiveResource::ResourceNotFound => e #FIXME system returns 404 in case of error. use 422 and proper formated xml
        logger.warn "Cannot reboot: #{e.inspect}"
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
		    # logout from the service, shut down is in progress
		    redirect_to(logout_path) and return
		else
		    flash[:error] = _("Cannot shutdown the machine!")
		end
	    rescue ActiveResource::ResourceNotFound => e #FIXME system returns 404 in case of error. use 422 and proper formated xml
        logger.warn "Cannot shutdown: #{e.inspect}"
		    flash[:error] = _("Cannot shutdown the machine!")
	    end
	else
	    flash[:error] = 'Shutdown request is accepted only via PUT method!'
	end

	redirect_to :controller => :controlpanel, :action => :index
    end
end

# vim: ft=ruby
