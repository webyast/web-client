require 'yast/service_resource'
require 'client_exception'

class RepositoriesController < ApplicationController

  before_filter :login_required
  layout 'main'

  # Initialize GetText and Content-Type.
  init_gettext 'yast_webclient_repositories'

  def attribute_mapping
    {
      :id => _('Alias'),
      :enabled 	=> _('Enabled'),
      :autorefresh => _('Autorefresh'),
      :name => _('Name'),
      :url => _('URL'),
      :priority => _('Priority'),
      :keep_packages => _('Keep downloaded packages')
    }
  end

  private :attribute_mapping

  def index
    begin
      @repos = Repository.find :all
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = _("Cannot read repository list.")
      return
    end

    return unless @repos
    @permissions = Repository.permissions
    Rails.logger.debug "Available repositories: #{@repos.inspect}"
  end

  def show
    if params[:id].blank?
      flash[:error] = _('Missing repository parameter')
      redirect_to :action => :index and return
    end

    begin
      @repo = Repository.find URI.escape(params[:id])
      @permissions = Repository.permissions

      return unless @repo

      @adding = false
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = _("Repository '#{params[:id]}' was not found.")
      redirect_to :action => 'index' and return
    end
  end

  def delete
    if params[:id].blank?
      flash[:error] = _('Missing repository parameter')
      redirect_to :action => 'index' and return
    end

    begin
      @repo = Repository.find URI.escape(params[:id])
      return unless @repo
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = _("Repository '#{params[:id]}' was not found.")
      redirect_to :action => 'index' and return
    end

    @repo.id = URI.escape(@repo.id)

    if @repo.destroy
      flash[:message] = _("Repository '#{@repo.name}' has been deleted.")
    end

    redirect_to :action => :index and return
  end

  def update
    if params[:id].blank?
      flash[:error] = _('Missing repository parameter')
      redirect_to :action => :index and return
    end

    begin
      @repo = Repository.find URI.escape(params[:id])
      @permissions = Repository.permissions
      return unless @repo
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = _("Repository '#{params[:id]}' was not found.")
      redirect_to :action => 'index' and return
    end

    if params[:repository].blank?
      flash[:error] = _("Cannot update repository '#{params[:id]}': missing parameters.")
      redirect_to :action => 'index' and return
    end

    repository = params[:repository]

    @repo.name = repository[:name]
    @repo.autorefresh = repository[:autorefresh] == '1'
    @repo.enabled = repository[:enabled] == '1'
    @repo.keep_packages = repository[:keep_packages] == '1'
    @repo.url = repository[:url]
    @repo.priority = repository[:priority]

    if !@repo.priority.blank? && !@repo.priority.match(/^[0-9]+$/)
      flash[:error] = _("Invalid priority")
      render :show and return
    end

    @repo.priority = @repo.priority.to_i

    @repo.id = URI.escape(@repo.id)

    begin
      if @repo.save
        flash[:message] = _("Repository '#{@repo.name}' has been updated.")
      else
        if @repo.errors.size > 0
          Rails.logger.error "Repository save failed: #{@repo.errors.full_messages}"
          flash[:error] = generate_error_messages @repo, attribute_mapping
          # clear the errors so they are also not displayed in the body
          @repo.errors.clear
        else
          flash[:error] = _("Cannot update repository '#{@repo.name}': Unknown error")
        end

        render :show and return
      end
    rescue ActiveResource::ServerError, ActiveResource::ResourceNotFound => ex
      begin
        Rails.logger.error "Received ActiveResource::ServerError: #{ex.inspect}"
        err = Hash.from_xml ex.response.body

        if !err['error']['message'].blank?
          Rails.logger.error "Cannot update repository '#{@repo.name}': #{err['error']['message']}"
        end

        flash[:error] = _("Cannot update repository '#{@repo.name}'}")
      rescue Exception => e
          # XML parsing has failed, display complete response
          flash[:error] = _("Unknown backend error: #{ex.response.body}")
          Rails.logger.error "Unknown backend error: #{ex.response.body}"
      end

      render :show and return
    end

    redirect_to :action => :index and return
  end

  def add
    @repo = Repository.new
    @permissions = Repository.permissions

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
    @permissions = Repository.permissions

    @repo = Repository.new
    repository = params[:repository]

    if repository.blank?
      flash[:error] = _('Missing repository parameters')
      redirect_to :action => :add and return
    end

    @repo.name = repository[:name]
    @repo.autorefresh = repository[:autorefresh] == '1'
    @repo.enabled = repository[:enabled] == '1'
    @repo.keep_packages = repository[:keep_packages] == '1'
    @repo.url = repository[:url]
    @repo.priority = repository[:priority]

    if !@repo.priority.blank? && !@repo.priority.match(/^[0-9]+$/)
      flash[:error] = _("Invalid priority")
      @adding = true
      render :show and return
    end

    @repo.priority = @repo.priority.to_i
    @repo.id = URI.escape(repository[:id] || '')

    begin
      if @repo.save
        flash[:message] = _("Repository '#{@repo.name}' has been added.")
      end
    rescue ActiveResource::ServerError, ActiveResource::ResourceNotFound => ex
      begin
        Rails.logger.error "Received error: #{ex.inspect}"
        err = Hash.from_xml ex.response.body

        if !err['error']['message'].blank?
          Rails.logger.error "Cannot create repository '#{@repo.name}': #{err['error']['message']}"
        end

        flash[:error] = _("Cannot create repository '#{@repo.name}'")
      rescue Exception => e
          Rails.logger.error "Exception: #{e}"
          # XML parsing has failed, display complete response
          flash[:error] = _("Unknown backend error")
          Rails.logger.error "Unknown backend error: #{ex.response.body}"
      end
      redirect_to :action => :add and return
    end

    redirect_to :action => :index and return
  end

  def set_status
    if params[:id].blank?
      render :text => _("Error: Missing repository id.") and return
    end

    if !params.has_key? :enabled
      render :text => _("Error: Missing 'enabled' parameter.") and return
    end

    enabled = params[:enabled] == 'true'
    Rails.logger.debug "Setting repository status: '#{params[:id]}' => #{enabled}"

    @repo = Repository.find URI.escape(params[:id])
    return unless @repo
    @permissions = Repository.permissions

    enabled_orig = @repo.enabled
    @repo.enabled = enabled
    @repo.id = URI.escape(@repo.id)

    error_string = ''

    begin
      @repo.save
    rescue ActiveResource::ServerError, ActiveResource::ResourceNotFound => ex
      begin
        Rails.logger.error "Received error: #{ex}"
        err = Hash.from_xml ex.response.body

        if !err['error']['message'].blank?
          Rails.logger.error "Cannot update repository '#{@repo.name}': #{err['error']['message']}"
        end

        error_string = _("Cannot update repository '#{@repo.name}'")
      rescue Exception => e
          # XML parsing has failed
          error_string = _("Unknown backend error.")
      end
    end

    # display the original value if an error occurred
    if !error_string.blank?
      @repo.enabled = enabled_orig
    end

    render :partial => 'repository_checkbox', :locals => {:error => error_string, :id => @repo.id, :enabled => @repo.enabled, :disabled => !@permissions[:write]}

  end

end
