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
    @first_basesystem_step = Basesystem.installed? && Basesystem.new.load_from_session(session).first_step?
    lang_param  = params[:eula] ? params[:eula][:text_lang] : params[:eula_lang]
    eula_params = lang_param ? { :lang => lang_param } : {:lang => current_locale}
    @eula = Eulas.find @eula_id, :params => eula_params
  end

  def update
    @eula                 = Eulas.find @eula_id
    @eula.text            = ""
    @eula.available_langs = []
    @eula.id              = @eula_id
    accepted = params[:eula] && params[:eula][:accepted] == "true"
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
    
    redirect_to :action => :show, :id => next_id, :eula_lang => (params[:eula] && params[:eula][:text_lang] || nil)
  end
end
