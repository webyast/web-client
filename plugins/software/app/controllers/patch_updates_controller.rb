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

require 'client_exception'

class PatchUpdatesController < ApplicationController

  before_filter :login_required
  layout 'main'

  # Initialize GetText and Content-Type.
  init_gettext "webyast-software-ui"

public

  # GET /patch_updates
  # GET /patch_updates.xml
  def index
    @permissions = Patch.permissions
    begin
      @patch_messages = Patch.find :all, :params => {:messages => true}
      unless @patch_messages.empty?
        msg = @patch_messages[0].message
        msg.gsub!('<br/>', ' ')
        flash[:warning] = _("There are patch installation messages available") + details(msg)
      end

      @patch_updates = Patch.find :all
    rescue ActiveResource::ServerError => e
      ce = ClientException.new e
      if ce.backend_exception_type ==  "PACKAGEKIT_ERROR"
        if ce.message.match /Repository (.*) needs to be signed/
          flash[:error] = _("Cannot read patch updates: GPG key for repository <em>%s</em> is not trusted.") % $1
        else
          flash[:error] = ce.message
        end
        @patch_updates = []
        @error = true
      elsif ce.backend_exception_type == "PACKAGEKIT_INSTALL"
        # patch update installation in progress
        # display the message and reload after a while
        flash[:info] = ce.message
        @patch_updates = []
        @error = true
        @reload = true
      else
        raise e
      end
    end
    logger.info "Available patches: #{@patch_updates.inspect}"
  end

  # this action is rendered as a partial, so it can't throw
  def show_summary
    error = nil
    patch_updates = nil
    refresh = false
    begin
       patch_updates = Patch.find :all, :params => {:background => params['background']}
       refresh = true
    rescue ActiveResource::UnauthorizedAccess => e
      # handle unauthorized error - the session timed out
      Rails.logger.error "Error: ActiveResource::UnauthorizedAccess"
      error = e
      error_string = ''
    rescue ActiveResource::ClientError => e
      error = ClientException.new(e)
      patch_updates = nil
      error_string = _("A problem occured when loading patch information.")
    rescue ActiveResource::ServerError => e
      error = ClientException.new(e)
      error_string = _("A problem occured when loading patch information.")
      error_string = error.message if error.backend_exception_type =~  /PACKAGEKIT_.*/
      refresh = true if error.backend_exception_type == "PACKAGEKIT_INSTALL" #refresh state of installation
      patch_updates = nil
    end    
    patches_summary = nil

    if patch_updates
      # is it a background progress?
      if patch_updates.size == 1 && patch_updates.first.respond_to?(:status)
        bg_stat = patch_updates.first

        patches_status = {:status => bg_stat.status, :progress => bg_stat.progress, :subprogress => bg_stat.subprogress}
        Rails.logger.debug "Received background patches progress: #{patches_status.inspect}"

        respond_to do |format|
          format.html { render :partial  => 'patch_progress', :locals => {:status => patches_status, :error => error} }
          format.json  { render :json => patches_status }
        end

        return
      else
        patches_summary = { :security => 0, :important => 0, :optional => 0}
        [:security, :important, :optional].each do |patch_type|
          patches_summary[patch_type] = patch_updates.find_all { |p| p.kind == patch_type.to_s }.size
        end
        # add 'low' patches to optional
        patches_summary[:optional] += patch_updates.find_all { |p| p.kind == 'low' }.size
      end
    else
      erase_redirect_results #reset all redirects
      erase_render_results
      flash.clear #no flash from load_proxy
    end

    # don't refresh if there was an error
    ref_timeout = refresh ? refresh_timeout : nil

    respond_to do |format|
      format.html { render :partial => "patch_summary", :locals => { :patch => patches_summary, :error => error, :error_string => error_string, :refresh_timeout => ref_timeout } }
      format.json  { render :json => patches_summary }
    end    
  end

  def load_filtered
    @permissions = Patch.permissions
    @patch_updates = Patch.find :all
    kind = params[:value]
    unless kind == "all"
      patches = @patch_updates.find_all { |patch| patch.kind == kind }

      # optional patches can also have kind 'low'
      if kind == 'optional'
        patches += @patch_updates.find_all { |patch| patch.kind == 'low' }
      end

      @patch_updates = patches
    end
    render :partial => "patches"
  end

  # POST /patch_updates/start_install_all
  # Starting installation of all proposed patches
  def start_install_all
    logger.info "Start installation of all patches"
    Patch.install_patches Patch.find(:all)
    show_summary
  end

  # POST /patch_updates/install
  # Installing one or more patches which has given via param 

  def install    
    update_array = []

    #search for patches and collect the ids
    params.each { |key, value|
      if key =~ /\D*_\d/ || key == "id"
        update_array << value
      end
    }
    
    Patch.install_patches_by_id update_array

    redirect_to :action => "index"
  end

  def license
    if params[:accept].present? || params[:reject].present?
      begin
        patch = params[:accept].present? ? Patch.create(:accept_license => 1) : Patch.create(:reject_license => 1)
      rescue ActiveResource::ServerError => e
        #ignore as it is probably continuing installation
        # FIXME better check
      end
      redirect_to "/"
      return
    end
    @permissions = Patch.permissions
    @license = Patch.find(:all, :params => {:license => 1}).first
  end



  private

  def refresh_timeout
    # the default is 24 hours
    timeout = ControlPanelConfig.read 'patch_status_timeout', 24*60*60

    if timeout.zero?
      Rails.logger.info "Patch status autorefresh is disabled"
    else
      Rails.logger.info "Autorefresh patch status after #{timeout} seconds"
    end

    return timeout
  end

end
