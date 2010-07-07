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
require 'systemtime'


# = SystemTimeController
# Provides all functionality, that handles time management module.
# The most functionality around time handling is in rest-service and this
# controller just provide handling of different exceptions and UI features.
# Update time and timezone is separated as timezone update doesn't neccesarry
# require also time update and that could set time to bad value.
class TimeController < ApplicationController
  before_filter :login_required
  layout 'main'

  public

  # cannot move to initialize, it is not finded - http://www.yotabanana.com/hiki/ruby-gettext-howto-rails.html#ApplicationController
  # Initialize GetText and Content-Type.
  init_gettext "webyast-time-ui"  # textdomain, options(:charset, :content_type)

  def initialize
    unless defined? @@timezones
      @@timezones = {}
    end
    @valid = []    
  end

  # Index handler. Loads information from backend and if success all required
  # fields is filled. In case of errors redirect to help page, main page or just
  # show flash with partial problem.
  def index
    @ntp = Ntp.find :one
    @stime = Systemtime.find :one
    @stime.load_timezone params if params[:timezone] #do not reset timezone if ntp fail (bnc#600370)
    @permissions = Systemtime.permissions
  end

  # Update time handler. Sets to backend new timezone and time.
  # If time is set to future it
  # still shows problems. Now it invalidate session for logged user.If
  # everything goes fine it redirect to index
  def update
    t = Systemtime.find :one
    t.load_timezone params
    t.clear_time #do not set time by default
    case params[:timeconfig]
    when "manual"
      Service.put("ntp", {:execute => "stop" })
      t.load_time params
    when "ntp_sync"
      #start ntp service
      ntp = Ntp.find :one
      ntp.actions.synchronize = true
      ntp.actions.synchronize_utc = t.utcstatus
      ntp.actions.ntp_server = params[:ntp_server] unless params[:ntp_server].blank?
      begin 
        ntp.save #FIXME check return value
      rescue Timeout::Error => e
        #do nothing as if you move time to future it throws this exception
        logger.info "Time moved to future by NTP"
      rescue ActiveResource::ServerError => e
        ce = ClientException.new e
        if ce.backend_exception_type == "NTP_ERROR"
          flash[:error] = ce.message
          redirect_to ({:action => "index"}.merge params) and return
        end
      end
      Service.put("ntp", {:execute => "start" })
    when "none" 
    else
      logger.error "Unknown value for timeconfig #{params[:timeconfig]}"
    end

    t.timezones = [] #save bandwitch

    begin
      t.save #TODO check return value
      flash[:notice] = _('Time settings have been written.')
    rescue Timeout::Error => e
      #do nothing as if you move time to future it throws this exception
      logger.debug "Time moved to future"
      flash[:notice] = _('Time settings have been written.')
    end

    redirect_success
  end


  #AJAX function that renders new timezones for selected region. Expected
  # initialized values from index call.
  def timezones_for_region
    #FIXME do not use AJAX use java script instead as reload of data is not needed
    # since while calling this function there is different instance of the class
    # than when calling index, @@timezones were empty; reinitialize them
    # possible FIXME: how does it increase the amount of data transferred?
    systemtime = Systemtime.find :one

    timezones = systemtime.timezones

    region = timezones.find { |r| r.name == params[:value] } #possible FIXME later it gets class, not a string
    return false unless region #possible FIXME: is returnign false for AJAX correct?

    render(:partial => 'timezones',
      :locals => {:region => region, :default => region.central,
        :disabled => ! params[:disabled]=="true"})
  end
end
