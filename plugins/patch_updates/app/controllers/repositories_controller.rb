require 'yast/service_resource'
require 'client_exception'

class RepositoriesController < ApplicationController

  before_filter :login_required
  layout 'main'
  include ProxyLoader

  # Initialize GetText and Content-Type.
  init_gettext 'yast_webclient_repositories'

  def index
    @repos = load_proxy 'org.opensuse.yast.system.repositories', :all
    return unless @repos
    Rails.logger.debug "Available repositories: #{@repos.inspect}"
  end

  def edit
    if params[:id].blank?
      flash[:error] = _('Missing repository parameter')
      redirect_to :action => :index and return
    end

    @repo = load_proxy 'org.opensuse.yast.system.repositories', params[:id]
    return unless @repo
  end

  def delete
    if params[:id].blank?
      flash[:error] = _('Missing repository parameter')
      redirect_to :action => 'index' and return
    end

    @repo = load_proxy 'org.opensuse.yast.system.repositories', params[:id]
    return unless @repo

    if @repo.destroy
      flash[:message] = _("Repository '#{@repo.id}' has been deleted.")
    end

    redirect_to :action => :index and return
  end

end
