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
  
  def index
    #TODO: add params to post request!
#     logger.error(" PARAMS #{params.inspect} *********")
    
#     @response = Notifier.find(:one, :params => { :plugin => "users", :id=>"" })
    
#     @response = Notifier.get("/notifier/status.xml", :params => { :plugin => :users, :id=>:all })
#     Product.find(:all, :params => { :search => 'table' }) # GET products.xml?search=table
    logger.error(" HTTP STATUS #{@response.inspect} *********")
    @response = Notifier.post(:plugin=>:users, :all=>'')
#     if @response.code.to_i == 304
#       respond_to do |format|
# 	format.js { render :text => 'ss', :status => 304 }
#       end
#     end
  end
end