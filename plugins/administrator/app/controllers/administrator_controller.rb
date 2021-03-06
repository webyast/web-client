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

require 'yast/service_resource'

class AdministratorController < ApplicationController
  before_filter :login_required

  private

  # Initialize GetText and Content-Type.
  init_gettext "webyast-root-user-ui"  # textdomain, options(:charset, :content_type)

  public

  def index
    @administrator	= Administrator.find :one
    @permissions	= Administrator.permissions
    @administrator.confirm_password	= ""
    params[:firstboot]	= 1 if Basesystem.installed? && Basesystem.new.load_from_session(session).in_process?
  end

  # PUT
  def update
    @administrator	= Administrator.find :one

    admin	= params["administrator"]
    @administrator.password	= admin["password"]
    @administrator.aliases	= admin["aliases"]
    # validate data also here, if javascript in view is off
    unless admin["aliases"].empty?
      admin["aliases"].split(",").each do |mail|
	# only check emails, not local users
        if mail.include?("@") && mail !~ /^.+@.+$/ #only trivial check
          flash[:error] = _("Enter a valid e-mail address.")
          redirect_to :action => "index"
          return
	end
      end
    end

    if admin["password"] != admin["confirm_password"] && ! params.has_key?("save_aliases")
      flash[:error] = _("Passwords do not match.")
      redirect_to :action => "index"
      return
    end

    # only save selected subset of administrator data:
    @administrator.password	= nil if params.has_key? "save_aliases"

    # we cannot pass empty string to rest-service
    @administrator.aliases = "NONE" if @administrator.aliases == ""

    begin
      response = @administrator.save
      flash[:notice] = _('Administrator settings have been written.')
      rescue ActiveResource::ClientError => e
        flash[:error] = YaST::ServiceResource.error(e)
	logger.warn e.inspect
      # handle ADMINISTRATOR_ERROR in backend exception here, not by generic handler
      rescue ActiveResource::ServerError => e
	error = Hash.from_xml e.response.body
	logger.warn error.inspect
	if error["error"] && error["error"]["type"] == "ADMINISTRATOR_ERROR"
	  # %s is detailed error message
          flash[:error] = _("Error while saving administrator settings: %s") % error["error"]["output"]
	else
	  raise e
	end
    end

    # check if mail is configured; during initial workflow, only warn if mail configuration does not follow
    if admin["aliases"] != "" && (defined?(Mail) == 'constant' && Mail.class == Class) &&
        (!Basesystem.installed? ||
         !Basesystem.new.load_from_session(session).following_steps.any? { |h| h[:controller] == "mail" })
      @mail       = Mail.find :one
      if @mail && (@mail.smtp_server.nil? || @mail.smtp_server.empty?)
	flash[:warning] = _("Mail alias was set but outgoing mail server is not configured (%s<i>change</i>%s).") % ['<a href="/mail">', '</a>']
      end
    end
    redirect_success
  end

end

# vim: ft=ruby
