require "yast/service_resource"
require 'enumerator'


class EulasController < ApplicationController
  before_filter :login_required
  before_filter :ensure_eula_list, :only => [:next, :show, :index]
  before_filter :ensure_id, :only => [:show, :update]

  layout 'main'
  include ProxyLoader

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_language"  # textdomain, options(:charset, :content_type)

  def load_proxy_without_permissions (*args)
    proxy = YaST::ServiceResource.proxy_for args[0]
    raise "No proxy_for for #{args[0]}" if proxy.nil?
    found_objects = proxy.find *(args[1..-1])
    raise "Error when proxy.find for #{args[0]}" if found_objects.nil?
    found_objects # can be array or single
  end

  def ensure_eula_list
    if session[:eula_unaccepted_ids_cache].nil? then
      eulas = load_proxy_without_permissions "org.opensuse.yast.modules.eulas", :all
      session[:eula_unaccepted_ids_cache] = eulas.to_enum(:each_with_index).collect{|eula,index| eula.accepted ? nil : (index+1)}.compact
    end
  end

  def ensure_id
    redirect_to :action => :next and return if params[:id].nil?
    @eula_id   = params[:id]
  end

  def index
    if session[:eula_unaccepted_ids_cache].empty? then
      render :all_accepted
    else
      redirect_to :action => :next
    end
  end

  def next
    next_id = session[:eula_unaccepted_ids_cache][0]
    if next_id.nil? then
      redirect_success
    else
      redirect_to :action => :show, :id => next_id, :eula_lang => params[:eula_lang]
    end
  end

  def show
    eula_params = params[:eula_lang].nil? ? Hash.new : { :lang => params[:eula_lang] }
    @eula = load_proxy_without_permissions "org.opensuse.yast.modules.eulas", @eula_id, :params => eula_params
  end

  def update
    @eula                 = load_proxy_without_permissions "org.opensuse.yast.modules.eulas", @eula_id
    @eula.text            = ""
    @eula.available_langs = []
    @eula.accepted        = params[:accepted]
    @eula.id              = @eula_id # XXX Why is this not set by the load_proxy !!!!
    @eula.save
    if @eula.accepted
      session[:eula_unaccepted_ids_cache].shift
    else
      flash[:error] = _("You must accept all licences before using this product!")
    end
    redirect_to :action => :next, :eula_lang => params[:eula_lang]
  end


end
