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

require 'enumerator'

class EulasController < ApplicationController
  before_filter :login_required
  before_filter :ensure_eula_count, :only => [:show, :index, :update]
  before_filter :ensure_id, :only => [:show, :update]

  layout 'main'

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_eulas"  # textdomain, options(:charset, :content_type)

private

  def ensure_eula_count
    if session[:eula_count].nil?
      eulas = Eulas.find :all
      session[:eula_count] = eulas.length
    end
    @eula_count = session[:eula_count]
  end

  def ensure_id
    redirect_to :action => :show, :id => 1 and return if params[:id].nil?
    @eula_id   = [1,params[:id].to_i].max
  end

  def next_in_range(range, current)
    [current+1, range.max].min
  end

  def prev_in_range(range, current)
    [current-1, range.min].max
  end

public

  def index
    if session[:eula_count] == 0
      render :no_licenses
    else
      redirect_to :action => :show, :id => 1
    end
  end

  def show
    @prev_id = prev_in_range( (1..@eula_count), @eula_id)
    @last_eula = @eula_id == @eula_count
    @first_eula= @eula_id == 1
    basesystem = Basesystem.installed? && Basesystem.new.load_from_session(session)
    @first_basesystem_step = basesystem ? basesystem.first_step? : false
    @basesystem_completed = basesystem ? basesystem.completed? : true
    @eula = Eulas.find @eula_id, :params => {:lang => current_locale}
    @permissions = Eulas.permissions
  end

  def update
    @eula                 = Eulas.find @eula_id
    @eula.text            = ""
    @eula.available_langs = []
    @eula.id              = @eula_id
    accepted = params[:eula] && params[:eula][:accepted] == "true"
    if accepted
      @eula.accepted = accepted
      @eula.save # do not save again if there is no change
      if @eula_count == @eula_id
        redirect_success
        return
      end
      next_id = next_in_range( (1..@eula_count), @eula_id)
    else
      flash[:error] = _("You must accept all licences before using this product!")
      next_id = @eula_id
    end
    redirect_to :action => :show, :id => next_id
  end
end
