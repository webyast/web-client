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

  def show
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

  def update
    if params[:id].blank?
      flash[:error] = _('Missing repository parameter')
      redirect_to :action => :index and return
    end

    @repo = load_proxy 'org.opensuse.yast.system.repositories', params[:id]
    return unless @repo

    repository = params[:repository]

    @repo.name = repository[:name]
    @repo.autorefresh = repository[:autorefresh]
    @repo.enabled = repository[:enabled]
    @repo.keep_packages = repository[:keep_packages]
    @repo.priority = repository[:priority].to_i

    if @repo.save
      flash[:message] = _("Repository '#{@repo.id}' has been updated.")
    end

    redirect_to :action => :show, :id => params[:id] and return
  end
end
