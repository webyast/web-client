#--
# Copyright (c) 2010 Novell, Inc.
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

require 'yast/service_resource'
require 'client_exception'

class ActivedirectoryController < ApplicationController

  before_filter :login_required
  before_filter :set_perm
  layout 'main'

  # Initialize GetText and Content-Type.
  init_gettext 'yast_webclient_activedirectory'


  def index
    begin
      @activedirectory = Activedirectory.find :one
      Rails.logger.debug "ad: #{@activedirectory.inspect}"
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = _("Cannot read Active Directory client configuraton.")
      @activedirectory		= nil
      @permissions	= {}
      render :index and return
    end

    return unless @activedirectory
    logger.debug "permissions: #{@permissions.inspect}"
  end

  def update
    begin
      params[:activedirectory][:create_dirs] = params[:activedirectory][:create_dirs] == "true"
      params[:activedirectory][:enabled] = params[:activedirectory][:enabled] == "true"
      @activedirectory = Activedirectory.new(params[:activedirectory])
      @activedirectory.save
      flash[:message] = _("Active Directory client configuraton successfully written.")
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      logger.warn e.inspect
    rescue ActiveResource::ServerError => e
      logger.warn e.inspect
      error = Hash.from_xml e.response.body
      # credentials required for joining the domain
      if error["error"] && error["error"]["type"] == "ACTIVEDIRECTORY_ERROR" && error["error"]["id"] == "not_member"
	flash[:mesage] = _("Machine is not member of given domain. Enter the credentials needed for join.")
	@activedirectory.administrator	= ""
	@activedirectory.password		= ""
	@activedirectory.machine		= ""
	render :index and return
      elsif error["error"] && error["error"]["type"] == "ACTIVEDIRECTORY_ERROR" && error["error"]["id"] == "join_error"
	flash[:error] = _("Error while jooining Active Directory domain: %s") % error["error"]["message"]
	render :index and return
      else
	flash[:error] = _("Error while saving Active Directory client configuration.")
      end
    end
    redirect_success
  end

private
  def set_perm
    @permissions = Activedirectory.permissions
  end
end
