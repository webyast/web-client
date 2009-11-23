require "yast/service_resource"
require 'enumerator'


class EulasController < ApplicationController
  before_filter :login_required
  before_filter :ensure_eula_count, :only => [:show, :index, :update]
  before_filter :ensure_id, :only => [:show, :update]

  layout 'main'
  include ProxyLoader

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_eulas"  # textdomain, options(:charset, :content_type)

  def load_proxy_without_permissions (*args)
    proxy = YaST::ServiceResource.proxy_for args[0]
    raise "No proxy_for for #{args[0]}" if proxy.nil?
    found_objects = proxy.find *(args[1..-1])
    raise "Error when proxy.find for #{args[0]}" if found_objects.nil?
    found_objects # can be array or single
  end

  def ensure_eula_count
    if session[:eula_count].nil?
      eulas = load_proxy_without_permissions "org.opensuse.yast.modules.eulas", :all
      session[:eula_count] = eulas.length
    end
    @eula_count = session[:eula_count]
  end

  def ensure_id
    redirect_to :action => :show, :id => 1 and return if params[:id].nil?
    @eula_id   = [1,params[:id].to_i].max
  end

  def index
    if session[:eula_count] == 0
      render :no_licenses
    else
      redirect_to :action => :show, :id => 1
    end
  end

  def next_in_range(range, current)
    [current+1, range.max].min
  end

  def prev_in_range(range, current)
    [current-1, range.min].max
  end

  def show
    @prev_id = prev_in_range( (1..@eula_count), @eula_id)
    @last_eula = @eula_id == @eula_count
    @first_eula= @eula_id == 1
    eula_params = params[:eula_lang].nil? ? Hash.new : { :lang => params[:eula_lang] }
    @eula = load_proxy_without_permissions "org.opensuse.yast.modules.eulas", @eula_id, :params => eula_params
  end

  def update
    @eula                 = load_proxy_without_permissions "org.opensuse.yast.modules.eulas", @eula_id
    @eula.text            = ""
    @eula.available_langs = []
    @eula.id              = @eula_id # XXX Why is this not set by the load_proxy !!!!
    accepted = (params[:accepted] == "true") || (params[:accepted] == true)
    if accepted
      unless @eula.accepted
        @eula.accepted = accepted
        @eula.save # do not save again if there is no change
      end
      if @eula_count == @eula_id
        redirect_success
        return
      end
      next_id = next_in_range( (1..@eula_count), @eula_id)
    elsif @eula.accepted
      flash[:error] = _("You cannot reject a license once it has been accepted!")
      next_id = @eula_id
    else
      flash[:error] = _("You must accept all licences before using this product!")
      next_id = @eula_id
    end
    
    redirect_to :action => :show, :id => next_id, :eula_lang => params[:eula_lang]
  end
end
