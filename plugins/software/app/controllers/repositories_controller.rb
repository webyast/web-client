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

require 'yast/service_resource'
require 'client_exception'

class RepositoriesController < ApplicationController

  before_filter :login_required
  layout 'main'

  # Initialize GetText and Content-Type.
  init_gettext 'webyast-software-ui'

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
      @repos = []
      @permissions = {}
      render :index and return
    end

    return unless @repos
    @permissions = Repository.permissions

    @show = params["show"]
    Rails.logger.debug "Displaying repository #{@show}" unless @show.blank?

    Rails.logger.debug "Available repositories: #{@repos.inspect}"
  end

  def delete
    if params[:id].blank?
      flash[:error] = _('Missing repository parameter')
      redirect_to :action => :index and return
    end

    begin
      @repo = Repository.find URI.escape(params[:id])
      return unless @repo
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = _("Repository '#{ERB::Util.html_escape params[:id]}' was not found.")
      redirect_to :action => :index and return
    end

    @repo.id = URI.escape(@repo.id)

    begin
      if @repo.destroy
        flash[:message] = _("Repository '#{ERB::Util.html_escape @repo.name}' has been deleted.")
      end
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = _("Cannot remove repository '#{ERB::Util.html_escape params[:id]}'")
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
      flash[:error] = _("Repository '#{ERB::Util.html_escape params[:id]}' was not found.")
      redirect_to :action => :index and return
    end

    if params[:repository].blank?
      flash[:error] = _("Cannot update repository '#{ERB::Util.html_escape params[:id]}': missing parameters.")
      redirect_to :action => :index, :show => params[:id] and return
    end

    repository = params[:repository]

    @repo.name = repository[:name]
    @repo.autorefresh = repository[:autorefresh] == 'true'
    @repo.enabled = repository[:enabled] == 'true'
    @repo.keep_packages = repository[:keep_packages] == 'true'
    @repo.url = repository[:url]
    @repo.priority = repository[:priority]

    if !@repo.priority.blank? && !@repo.priority.match(/^[0-9]+$/)
      flash[:error] = _("Invalid priority")
      redirect_to :action => :index, :show => params[:id] and return
    end

    @repo.priority = @repo.priority.to_i

    @repo.id = URI.escape(@repo.id)

    begin
      if @repo.save
        flash[:message] = _("Repository '#{ERB::Util.html_escape @repo.name}' has been updated.")
      else
        if @repo.errors.size > 0
          Rails.logger.error "Repository save failed: #{@repo.errors.errors.inspect}"
          flash[:error] = generate_error_messages @repo, attribute_mapping
        else
          flash[:error] = _("Cannot update repository '#{ERB::Util.html_escape @repo.name}': Unknown error")
        end
      end
    rescue ActiveResource::ServerError, ActiveResource::ResourceNotFound => ex
      begin
        Rails.logger.error "Received ActiveResource::ServerError: #{ex.inspect}"
        err = Hash.from_xml ex.response.body

        if !err['error']['message'].blank?
          Rails.logger.error "Cannot update repository '#{@repo.name}': #{err['error']['message']}"
        end

        flash[:error] = _("Cannot update repository '#{ERB::Util.html_escape @repo.name}'}")
      rescue Exception => e
          # XML parsing has failed, display complete response
          flash[:error] = _("Unknown backend error: #{ERB::Util.html_escape ex.response.body}")
          Rails.logger.error "Unknown backend error: #{ex.response.body}"
      end
    end

    redirect_to :action => :index, :show => params[:id] and return
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

    # load URLs of all existing repositories
    repos = Repository.find :all
    @repo_urls = repos.map {|r| r.url}
    @repo_urls.reject! {|u| u.blank? }
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
    @repo.autorefresh = repository[:autorefresh] == 'true'
    @repo.enabled = repository[:enabled] == 'true'
    @repo.keep_packages = repository[:keep_packages] == 'true'
    @repo.url = repository[:url]
    @repo.priority = repository[:priority]

    if !@repo.priority.blank? && !@repo.priority.match(/^[0-9]+$/)
      flash[:error] = _("Invalid priority")
      @repo.priority = 99
      @repo_urls = []
      render :add and return
    end

    @repo.priority = @repo.priority.to_i
    @repo.id = URI.escape(repository[:id] || '')

    begin
      if @repo.save
        flash[:message] = _("Repository '#{ERB::Util.html_escape @repo.name}' has been added.")
      end
    rescue ActiveResource::ServerError, ActiveResource::ResourceNotFound => ex
      begin
        Rails.logger.error "Received error: #{ex.inspect}"
        err = Hash.from_xml ex.response.body

        if !err['error']['message'].blank?
          Rails.logger.error "Cannot create repository '#{ERB::Util.html_escape @repo.name}': #{ERB::Util.html_escape err['error']['message']}"
        end

        flash[:error] = _("Cannot create repository '#{ERB::Util.html_escape @repo.name}'")
      rescue Exception => e
          Rails.logger.error "Exception: #{e}"
          # XML parsing has failed, display complete response
          flash[:error] = _("Unknown backend error")
          Rails.logger.error "Unknown backend error: #{ex.response.body}"
      end
      redirect_to :action => :add and return
    end

    redirect_to :action => :index, :show => repository[:id] and return
  end

end
