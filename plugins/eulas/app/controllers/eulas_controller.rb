require "yast/service_resource"


class EulasController < ApplicationController
  before_filter :login_required
  before_filter :ensure_eula_list, :only => [:next, :show]

  layout 'main'
  include ProxyLoader

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_language"  # textdomain, options(:charset, :content_type)

  def ensure_eula_list
    if session[:eula_unaccepted_ids].nil? then
      eulas = load_proxy "org.opensuse.yast.modules.eulas", :all
      session[:eula_unaccepted_ids] = eulas.each_with_index{|eula,index| eula.accepted ? nil : (index+1)}.compact
    end
  end

  def index 
    redirect_to :action => :next
  end

  def next
    next_id = session[:eula_unaccepted_ids][0]
    if next_id.nil? then
      render :all_accepted
    else
      redirect_to :action => :show, :id => next_id
    end
  end

  def show
    redirect_to :action => :next and return if params[:id].nil?
    @eula      = load_proxy "org.opensuse.yast.modules.eulas", params[:id].nil?
    @last_eula = session[:eula_unaccepted_ids].length == 1
  end

end
