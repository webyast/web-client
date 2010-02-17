require 'yast/service_resource'
require 'client_exception'

class RepositoriesController < ApplicationController

  before_filter :login_required
  layout 'main'
  include ProxyLoader
  #don't add load_proxy as action for controller
  hide_action :load_proxy

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

    @repo = load_proxy 'org.opensuse.yast.system.repositories', URI.escape(params[:id])
    return unless @repo

    @adding = false
  end

  def delete
    if params[:id].blank?
      flash[:error] = _('Missing repository parameter')
      redirect_to :action => 'index' and return
    end

    @repo = load_proxy 'org.opensuse.yast.system.repositories', URI.escape(params[:id])
    return unless @repo

    @repo.id = URI.escape(@repo.id)

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

    @repo = load_proxy 'org.opensuse.yast.system.repositories', URI.escape(params[:id])
    return unless @repo

    repository = params[:repository]

    @repo.name = repository[:name]
    @repo.autorefresh = repository[:autorefresh]
    @repo.enabled = repository[:enabled]
    @repo.keep_packages = repository[:keep_packages]
    @repo.url = repository[:url]
    @repo.priority = repository[:priority].to_i

    @repo.id = URI.escape(@repo.id)

    begin
      if @repo.save
        flash[:message] = _("Repository '#{params[:id]}' has been updated.")
      end
    rescue ActiveResource::ServerError => ex
      begin
        Rails.log.error "Received ActiveResource::ServerError: #{ex.inspect}"
        err = Hash.from_xml ex.response.body

        if !err['error']['description'].blank?
          flash[:error] = _("Cannot update repository '#{params[:id]}': #{err['error']['description']}")
        else
          flash[:error] = _("Unknown backend error.")
        end
      rescue Exception => e
          # XML parsing has failed, display complete response
          flash[:error] = _("Unknown backend error: #{ex.response.body}")
      end

      redirect_to :action => :show, :id => params[:id] and return
    end

    redirect_to :action => :index and return
  end

  def add
    # load only permissions
    @client = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.repositories')
    @permissions = @client.permissions

    @repo = @client.new

    # add default properties
    defaults = {
      :id => '',
      :name => '',
      :url => 'http://',
      :autorefresh => true,
      :enabled => true,
      :keep_packages => false,
      :priority => 99
    }

    @repo.load(defaults)

    @adding = true

    render :show
  end

  def create
    # load only permissions
    @client = YaST::ServiceResource.proxy_for('org.opensuse.yast.system.repositories')
    @permissions = @client.permissions

    @repo = @client.new
    repository = params[:repository]
    @repo.load(repository)

    @repo.id = URI.escape(@repo.id)

    begin
      if @repo.save
        flash[:message] = _("Repository '#{params[:id]}' has been added.")
      end
    rescue ActiveResource::ServerError => ex
      begin
        Rails.log.error "Received ActiveResource::ServerError: #{ex.inspect}"
        err = Hash.from_xml ex.response.body

        if !err['error']['description'].blank?
          flash[:error] = _("Cannot update repository '#{params[:id]}': #{err['error']['description']}")
        else
          flash[:error] = _("Unknown backend error.")
        end
      rescue Exception => e
          # XML parsing has failed, display complete response
          flash[:error] = _("Unknown backend error: #{ex.response.body}")
      end
    end

    redirect_to :action => :index and return
  end

  def set_status
    if params[:id].blank?
    end

    enabled = params[:enabled] == 'true'
    Rails.logger.debug "Setting repository status: '#{params[:id]}' => #{enabled}"

    @repo = load_proxy 'org.opensuse.yast.system.repositories', URI.escape(params[:id])
    return unless @repo

    @repo.enabled = enabled
    @repo.id = URI.escape(@repo.id)

    error_string = ''

    begin
      @repo.save
    rescue ActiveResource::ServerError => ex
      begin
        Rails.logger.error "Received ActiveResource::ServerError: #{ex.inspect}"
        err = Hash.from_xml ex.response.body

        if !err['error']['description'].blank?
          error_string = _("Cannot update repository '#{params[:id]}': #{err['error']['description']}")
        else
          error_string = _("Unknown backend error.")
        end
      rescue Exception => e
          # XML parsing has failed
          error_string = _("Unknown backend error.")
      end
    end

    render :partial => 'repository_checkbox', :locals => {:error => error_string, :id => @repo.id, :enabled => @repo.enabled, :disabled => !@permissions[:write]}

  end

  end
