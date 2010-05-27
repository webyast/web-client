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

# = Registration controller
# Provides all functionality, that handles system registration.

class RegistrationController < ApplicationController
  before_filter :login_required
  layout 'main'

  def initialize
    @trans = {  'email' => _("Email"),
                'moniker' => _("System name"),
                'regcode-sles' => _("SLES registration code"),
                'regcode-sled' => _("SLED registration code"),
                'appliance-regcode' => _("Appliance registration code"),
                'regcode-webyast'   => _("WebYaST registration code"),
                '___getittranslated1' => _("Registration code"),
                '___getittranslated2' => _("Hostname"),
                '___getittranslated3' => _("Device name"),
                '___getittranslated4' => _("Appliance name"),
                '___getittranslated5' => _("registration code")
             }
    @trans.freeze
  end

  private
  def client_permissions
    @client = YaST::ServiceResource.proxy_for('org.opensuse.yast.modules.registration.registration')
    unless @client
      flash[:notice] = _("Invalid session, please login again.")
      redirect_to( logout_path ) and return
    end
    @client.timeout = 120 #increasing server timeout cause registration can take a while
    @permissions = @client.permissions
    @options = {'debug'=>2 }
    @arguments = []
  end

  def register_permissions
    unless @permissions[:statelessregister]
      flash[:warning] = _("No permissions for registration")
      redirect_to root_path
      return false
    end
    true
  end

  def translate_argument_key(key)
    return '-unknown-' unless key
    return @trans[key] if ( @trans.kind_of?(Hash) && @trans[key] )
    key
  end

  def sort_arguments(args)
    begin
      args.collect! do |arg|
        arg['description'] = translate_argument_key( arg.kind_of?(Hash) ? arg['name'] : nil )
        arg
      end
      # sort by names alphabetically
      return args.sort! { |a,b|  a['name'] <=> b['name'] }
    rescue
      return Array.new
    end
  end

  # Initialize GetText and Content-Type.
  init_gettext "webyast-registration-ui"  # textdomain, options(:charset, :content_type)

  def client_guid
    # handle config error in backend (bnc#592620)
    begin
      status = @client.find
    rescue
      logger.debug "Registration could not find registration information: system is unregistered."
    end

    begin
      @guid = status.guid if (status.respond_to?('guid') && !status.guid.blank?)
      @config_error = true if (status.respond_to?('configerror') && status.configerror == 'true')
      logger.debug "found GUID: #{@guid}"
    rescue
      logger.error "Registration could neither read guid nor detect a configuration error."
    end

    return @guid
  end

  def try_again_msg
    _("Please try to register again later.")
  end

  def registration_skip_flash
    error_line1 = "<b>" + _("Registration was skipped.") + "</b>"
    error_line2 = "The system might not receive necessary updates."
    return error_line1 + "<p>" + error_line2 + "<br />" + try_again_msg + "</p>"
  end

  def server_error_flash(msg)
    error_heading_old = _("Registration did not finish.")
    error_heading =     _("Registration did not succeed.")
    error_line1 = "<b>" + error_heading + "</b>"
    error_line2 = ( msg || "" ) + " " + _("This may be a temporary issue.")
    return error_line1 + "<p>" + error_line2 + "<br />" + try_again_msg + "</p>"
  end

  def registration_logic_error
    flash[:error] = server_error_flash _("The registration server returned invalid or incomplete data.")
    logger.error "Registration resulted in an error, registration server or SuseRegister backend returned invalid or incomplete data."
    # success: allow users to skip registration in case of an error (bnc#578684) (bnc#579463)
    redirect_success
  end

  def registration_backend_error
    logger.error "Registration could not read the configuration. Most likely the backend is not installed correctly. Please check the package dependencies."
    flash[:error] = _("Could not read the registration configuration.") + "<br>" + _("The registration backend is not installed correctly") +
                    " " + _("Please refer to your support contact.")
  end

  def collect_missing_arguments(missed_args)
    arg_error_count = 0
    begin
      @arguments.collect! do |argument|
        missed_args.each do |missed_arg|
          if missed_arg["name"] == argument["name"] then
            if argument["value"] != missed_arg["value"] then
              # flag error if value is rejected by registration server
              argument["error"] = true if missed_arg["flag"] == "m"
              arg_error_count += 1
            end
            argument["value"] = missed_arg["value"]
            argument["flag"] = missed_arg["flag"]
            argument["kind"] = missed_arg["kind"]
            missed_args.reject! {|del_arg| del_arg["name"] == argument["name"] }
            break
          end
        end
        argument
      end
    rescue
      logger.error "Registration process can not collect the argument details."
    end

    # add remaining arguments to the list
    @arguments.concat(missed_args)
    flash[:error] = _("Please fill out missing entries.") if arg_error_count > 0
  end

  def split_arguments
    begin
      # split arguments into two lists to show them separately and sort each list to show them in a unique order
      @arguments_mandatory = sort_arguments( @arguments.select { |arg| (arg["flag"] == "m") if arg.kind_of?(Hash) } )
      @arguments_automatic = sort_arguments( @arguments.select { |arg| (arg["flag"] == "a") if arg.kind_of?(Hash) } )
      @arguments_detail    = sort_arguments( @arguments.select { |arg| ( (arg["flag"] != "m") && (arg["flag"] != "a") ) if arg.kind_of?(Hash) } )
    rescue
      logger.error "Registration found invalid argument data. Nothing to display to the user."
      @arguments_mandatory = []
      @arguments_automatic = []
      @arguments_detail = []
    end
  end

  def sources_changes_flash(msg='')
    # use an own type for this message
    # because it needs to be displayed and bypass the UI-expert-filter (bnc600842)
    ftype = :repoinfo
    flash[ftype] ||= ''
    flash[ftype] += msg
  end

  def check_service_changes
    begin
      if @changed_services && @changed_services.kind_of?(Array) && @changed_services.size > 0 then
        flash_msg = "<ul>"
        @changed_services.each do |c|
          if c.respond_to?(:name) && c.name && c.respond_to?(:status) && c.status == 'added' then
            flash_msg += "<li>" + _("Service added:") + " #{c.name}</li>"
          end
          if c.respond_to?(:catalogs) && c.catalogs && c.catalogs.respond_to?(:catalog) && c.catalogs.catalog then
            if c.catalogs.catalog.respond_to?(:name) && c.catalogs.catalog.respond_to?(:status) && c.catalogs.catalog.status == 'added' then
              flash_msg += "<ul><li>" + _("Catalog enabled:") + " #{c.catalogs.catalog.name}</li></ul>"
            elsif c.catalogs.catalog.kind_of?(Array) then
              flash_msg += "<ul>"
              c.catalogs.catalog.each do |s|
                if s && s.respond_to?(:name) && s.respond_to?(:status) && s.status == 'added' then
                  flash_msg += "<li>" + _("Catalog enabled:") + " #{s.name}</li>"
                end
              end
              flash_msg += "</ul>"
            end
          end
        end
        flash_msg += "</ul>"
        sources_changes_flash flash_msg
      else
        return false
      end
    rescue
      logger.error "Registration could not check the services for changes."
      return false
    end
    true
  end

  def check_repository_changes
    begin
      if @changed_repositories && @changed_repositories.kind_of?(Array) && @changed_repositories.size > 0 then
        flash_msg = "<ul>"
        @changed_repositories.each do |r|
          if r.respond_to?(:name) && r.name && r.respond_to?(:status) && r.status == 'added' then
            flash_msg += "<li>" + _("Repository added:") + " #{r.name}</li>"
          end
        end
        flash_msg += "</ul>"
        sources_changes_flash flash_msg
      else
        return false
      end
    rescue
      logger.error "Registration could not check the repositories for changes."
      return false
    end
    true
  end

  public

  def index
    return unless client_permissions
    return unless register_permissions

    client_guid
    if @config_error
      registration_backend_error
      redirect_success
      return
    end

    if !@guid
      @arguments = []
      @nexttarget = 'update'
      register
    else
      @showstatus = true
    end

  end

  def skip
    return unless client_permissions
    return unless register_permissions
    # redirect to the appropriate next target and show skip message
    flash[:warning] = registration_skip_flash if !client_guid
    redirect_success
    return
  end

  def reregister
    # provide a way to force a new registration, even if system is already registered
    @reregister = true
    @nexttarget = 'reregister'
    register
  end

  def update
    @nexttarget = 'update'
    register
  end

  def register
    return unless client_permissions
    return unless register_permissions

    client_guid
    if @config_error
      registration_backend_error
      redirect_success
      return
    end

    # redirect in case of interrupted basesetup
    if @guid && !@reregister
      flash[:warning] = _("This system is already registered.")
      redirect_success
      return
    end

    begin
      params.each do | key, value |
        if key.starts_with? "registration_arg_"
          argument = Hash.new
          argument["name"] = key[17, key.size-17]
          argument["value"] = value
          @arguments << argument
        end
      end
    rescue
      logger.debug "No arguments were passed to the registration call."
    end

    @changed_repositories = []
    @changed_services = []
    success = false
    begin
      register = @client.create({ :arguments => { 'argument' => @arguments },
                                  :options => @options })
      logger.debug "registration finished: #{register.to_xml}"

      if register.respond_to?(:status) && register.status == "finished" then
        @changed_repositories = register.changedrepos if register.respond_to? :changedrepos
        @changed_services = register.changedservices if register.respond_to? :changedservices
        flash[:notice] = _("Registration finished successfully.")
        success = true
      else
        logger.error "Registration is in success mode, but the backend returned no status information."
        return registration_logic_error
      end

      # display warning if no repos/services are added/changed during registration (bnc#558854)
      if !check_service_changes && !check_repository_changes
      then
        flash[:warning] = _("<p><b>Repositories were not modified during the registration process.</b></p><p>It is likely that an incorrect registration code was used. If this is the case, please attempt the registration process again to get an update repository.</p><p>Please make sure that this system has an update repository configured, otherwise it will not receive updates.</p>")
      end

    rescue ActiveResource::ClientError => e
      error = Hash.from_xml(e.response.body)["registration"]
      logger.debug "Error mode in registration process: #{error.inspect}"

      unless error && error.kind_of?(Hash) && error["status"] then
        logger.error "Registration is in error mode but no error status information is provided from the backend."
        return registration_logic_error
      end

      if error["status"] == "missinginfo" && !error["missingarguments"].blank?
        logger.debug "missing arguments #{error["missingarguments"].inspect}"
        logger.info "Registration is in needinfo - more information is required"
        # collect and merge the argument data
        collect_missing_arguments error["missingarguments"]

      elsif error["status"] == "finished"
        # status is "finished" but we are in rescure block - this does not fit
        logger.error "Registration finished successfully (according to backend), but it returned an error (http status 4xx)."
        logger.error "The registration status is unknown."
        return registration_logic_error

      elsif error["status"] == "error"
        e_exitcode = error["exitcode"] || 0
        e_exitcode = e_exitcode.to_i
        e_exitcode = 'unknown' if e_exitcode == 0

        logger.error "Registration resulted in an error, ID: #{e_exitcode}."
        case e_exitcode
        when  2, 199 then
          # 2 and 199 means that even the initialization of the backend did not succeed
          logger.error "Registration backend could not be initialized. Maybe due to network problem, SSL certificate issue or blocked by firewall."
          flash[:error] = server_error_flash _("A connection to the registration server could not be established.")
        when  3 then
          # 3 means that there is a conflict with the sent and the required data - it could not be solved by asking again
          logger.error "Registration data is conflicting. Contact your vendor."
          flash[:error] = server_error_flash _("The transmitted registration data created a conflict.")
        when 99 then
          # 99 is an internal error id for missing error status or missing exit codes
          logger.error "Registration backend sent no or invalid data. Maybe network problem or slow connection or too much load on registration server."
          return registration_logic_error
        when 100..101 then
          # 100 and 101 means that no product is installed that can be registered (100: no product, 101: FACTORY)
          logger.error "Registration process did not find any products that can be registered."
          flash[:error] = "<b>" + _("Registration can not be performed. There is no product installed that can be registered.") + "</b>"
        else
          # unknown error
          logger.error "Registration backend returned an unknown error. Please run in debug mode and report a bug."
          return registration_logic_error
        end
        redirect_success
        return
      else
        logger.debug "error while registration: #{error.inspect}"
        logger.error "Registration resulted in an error: Server returned invalid data"
        return registration_logic_error
      end

    rescue Exception => e
      flash[:error] = server_error_flash _("A connection to the registration server could not be established or it did not reply.")
      logger.error "Registration resulted in an error, execution of SuseRegister backend expired: Maybe network problem or severe configuration error."
      redirect_success
      return
    end

    if success
      logger.info "Registration succeed"
      redirect_success
    else
      logger.info "Registration is not yet finished"

      # split into madatory and detail arguments
      split_arguments

      if @arguments_mandatory.blank? && @arguments_detail.blank? then
        # redirect if the registration server is in needinfo but arguments list is empty
        flash[:error] = server_error_flash _("The registration server returned invalid data.")
        logger.error "Registration resulted in an error: Logic issue, unspecified data requested by registration server"
        redirect_success
        return
      end

      render :action => "index"
    end
  end
end
