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


require "notifier"

class NotifierController < ApplicationController
  layout nil

  def index
    #is needed cause logout is derived from base only
    Notifier.set_web_service_auth(YaST::ServiceResource::Session.auth_token)
    Notifier.init_service_url(YaST::ServiceResource::Session.site)

    if params[:plugin].include? "," 
      #there are more values that have to be checked for changes
      modules = params[:plugin].split ","
      status = "500"

      modules.each do | m |
    	http_code = Notifier.post(:status, :plugin => m).code.to_s

	    if http_code != "304"
	      Rails.logger.error "WARNING: HTTP CODE #{http_code}"
	      render :nothing=>true, :text=>http_code and return
	    else
	      status = http_code
	    end
      end

      render :nothing=>true, :text=>status and return

    else
      if params[:id]
      	@response = Notifier.post(:status, :plugin => params[:plugin], :id=>params[:id])
      else
      	@response = Notifier.post(:status, :plugin => params[:plugin])
      end

      logger.debug(" return HTTP STATUS #{@response.code.to_s}")
      render :nothing=>true, :text=>@response.code.to_s and return
    end
  end
end

