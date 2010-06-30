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
    @permissions = Activedirectory.permissions
    logger.debug "permissions: #{@permissions.inspect}"
  end

  def update
    begin
      params[:activedirectory][:create_dirs] = params[:activedirectory][:create_dirs] == "true"
      params[:activedirectory][:enabled] = params[:activedirectory][:enabled] == "true"
      @activedirectory = Activedirectory.new(params[:activedirectory]).save
      flash[:message] = _("Active Directory client configuraton successfully written.")
# FIXME check for not_member exception, ask for credentials
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      logger.warn e.inspect
    rescue ActiveResource::ServerError => e
      flash[:error] = _("Error while saving Active Directory client configuration.")
      logger.warn e.inspect
    end
    redirect_success
  end

end
