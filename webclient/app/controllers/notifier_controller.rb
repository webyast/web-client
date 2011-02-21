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
#   before_filter :login_required
  layout nil
  #Remove layouts for all ajax calls
#   layout proc{ |c| c.request.xhr? ? false : "application" }
  
  
  def index
    #TODO: add params to post request!
    logger.error(" PARAMS #{params.inspect} *********")
    
    @response = Notifier.post(:status, :plugin => params[:plugin], :id=>params[:id])
    logger.error(" HTTP STATUS #{@response.code.to_i} *********")
    render :nothing=>true, :text=>@response.code.to_i and return
  end
end