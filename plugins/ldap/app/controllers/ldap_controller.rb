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

class LdapController < ApplicationController

  before_filter :login_required
  layout 'main'

  # Initialize GetText and Content-Type.
  init_gettext 'yast_webclient_ldap'


  def index
    begin
      @ldap = Ldap.find :one
      Rails.logger.debug "ldap: #{@ldap.inspect}"
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = _("Cannot read LDAP client configuraton.")
      @ldap		= nil
      @permissions	= {}
      render :index and return
    end

    return unless @ldap
    @permissions = Ldap.permissions
    logger.debug "permissions: #{@permissions.inspect}"
  end

  # try to get base DN provided by given LDAP server
  def fetch_dn
    fetched = Ldap.find(:one,:params => {:fetch_dn => true, :server => params[:server]})
    render :text => "$('#ldap_base_dn').val('#{fetched.dn}');"
  end

  def update
    begin
      #translate from text to boolean
      params[:ldap][:tls] = params[:ldap][:tls] == "true"
      params[:ldap][:enabled] = params[:ldap][:enabled] == "true"
      @ldap = Ldap.new(params[:ldap]).save
      flash[:message] = _("LDAP client configuraton successfully written.")
    rescue ActiveResource::ClientError => e
      flash[:error] = YaST::ServiceResource.error(e)
      logger.warn e.inspect
    rescue ActiveResource::ServerError => e
      flash[:error] = _("Error while saving LDAP client configuration.")
      logger.warn e.inspect
    end
    redirect_success
  end

end
