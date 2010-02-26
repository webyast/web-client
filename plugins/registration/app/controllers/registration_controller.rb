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
  init_gettext "yast_webclient_registration"  # textdomain, options(:charset, :content_type)

  def client_guid
    begin
      status = @client.find
      @guid = status.guid unless status.guid.blank?
      logger.debug "found GUID: #{@guid}"
    rescue
      @guid = nil
      logger.debug "no GUID found"
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
    error_old = _("Error occured while connecting to registration server.")
    error_line1 = "<b>" + _("Registration did not finish.") + "</b>"
    error_line2 = ( msg || "" ) + " " + _("This may be a temporary issue.")
    return error_line1 + "<p>" + error_line2 + "<br />" + try_again_msg + "</p>"
  end

  public

  # Index handler. Loads information from backend and if success all required
  # fields are filled. In case of errors redirect to help page, main page or just
  # show flash with partial problem.
  def index
    return unless client_permissions
    return unless register_permissions

    if !client_guid
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

    # redirect in case of interrupted basesetup
    if client_guid && !@reregister
      flash[:notice] = _("This system is already registered.")
      redirect_success
      return
    end

    begin
      params.each do | key, value |
        if key.starts_with? "registration_arg,"
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
      register = @client.create({:arguments=> { 'argument' => @arguments },
                                 :options=>@options})
      logger.debug "registration finished: #{register.to_xml}"
      @changed_repositories = register.changedrepos if register.respond_to? :changedrepos
      @changed_services = register.changedservices if register.respond_to? :changedservices
      flash[:notice] = _("Registration finished successfully.")
      success = true

      # inform about added services and its catalogs
      if @changed_services && @changed_services.kind_of?(Array) && @changed_services.size > 0 then
        flash[:notice] += "<ul>"
        @changed_services.each do |c|
          if c.respond_to?(:name) && c.name && c.respond_to?(:status) && c.status == 'added' then
            flash[:notice] += "<li>" + _("Service added:") + " #{c.name}</li>"
          end
          if c.respond_to?(:catalogs) && c.catalogs && c.catalogs.respond_to?(:catalog) && c.catalogs.catalog then
            if c.catalogs.catalog.respond_to?(:name) && c.catalogs.catalog.respond_to?(:status) && c.catalogs.catalog.status == 'added' then
              flash[:notice] += "<ul><li>" + _("Catalog enabled:") + " #{c.catalogs.catalog.name}</li></ul>"
            elsif c.catalogs.catalog.kind_of?(Array) then
              flash[:notice] += "<ul>"
              c.catalogs.catalog.each do |s|
                if s && s.respond_to?(:name) && s.respond_to?(:status) && s.status == 'added' then
                  flash[:notice] += "<li>" + _("Catalog enabled:") + " #{s.name}</li>"
                end
              end
              flash[:notice] += "</ul>"
            end
          end
        end
        flash[:notice] += "</ul>"
      else
        no_services = true
      end

      # inform about added repositories
      if @changed_repositories && @changed_repositories.kind_of?(Array) && @changed_repositories.size > 0 then
        flash[:notice] += "<ul>"
        @changed_repositories.each do |r|
          if r.respond_to?(:name) && r.name && r.respond_to?(:status) && r.status == 'added' then
            flash[:notice] += "<li>" + _("Repository added:") + " #{r.name}</li>"
          end
        end
        flash[:notice] += "</ul>"
      else
        no_repos = true
      end

      # display warning message if no repos are added/changed during registration (bnc#558854)
      if no_services && no_repos
      then
        flash[:warning] = _("<p><b>Repositories were not modified during the registration process.</b></p><p>It is likely that an incorrect registration code was used. If this is the case, please attempt the registration process again to get an update repository.</p><p>Please make sure that this system has an update repository configured, otherwise it will not receive updates.</p>")
        #OLD flash[:warning] = _("No repositories were added or changed during the registration process (maybe due to a wrong registration code). If this system already has an update repository everything is fine. But without an update repository this system will not receive any updates. You may run the registration module again.")
      end


    ## just for a test
    # rescue ActiveResource::ServerError => e
    #  logger.error "500500500500500500500500500500500"
    #  logger.error e.inspect
    #  flash[:error] = "500500500500500500500500500500500"

    # FIXME - Need to catch a 404 from the rest_service, but nothing catches it - FIXME
    #rescue ActiveResource::ResourceNotFound => e
    #  logger.error "404404404404404404404404404404404"
    #  logger.error e.inspect
    #  flash[:error] = "404404404404404404404404404404404"
    rescue ActiveResource::ClientError => e
      arg_error_count = 0
      error = Hash.from_xml(e.response.body)["registration"]
      if error && error["status"] == "missinginfo" && !error["missingarguments"].blank?
        logger.debug "missing arguments #{error["missingarguments"].inspect}"
        #compare this with already existing arguments
        missed_args = error["missingarguments"]
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

        # add remaining arguments to the list
        @arguments.concat(missed_args)
        flash[:error] = _("Please fill out missing entries.") if arg_error_count > 0
        logger.info "Registration is in needinfo - more information is required"
      else
        logger.error "error while registration: #{error.inspect}"
        flash[:error] = server_error_flash _("The registration server returned invalid data.")
        logger.error "Registration resulted in an error: Server returned invalid data"
        # success: allow users to skip registration in case of an error (bnc#578684) (bnc#579463)
        redirect_success
        return
      end
    rescue Exception => e
      flash[:error] = server_error_flash _("The registration server was not reachable due to network or registration server problems.")
      logger.error "Registration resulted in an error: Network problem"
      redirect_success
      return
    end

    # redirect if the registration server is in needinfo but arguments list is empty
    if !@arguments || @arguments.size < 1
    then
      flash[:error] = server_error_flash _("The registration server returned invalid data.")
      logger.error "Registration resulted in an error: Logic issue, unspecified data requested by registration server"
      redirect_success
      return
    end

    # split in two lists to show them separately and sort each list to show it in a unique order
    @arguments_mandatory = sort_arguments( @arguments.select { |arg| (arg["flag"] == "m") if arg.kind_of?(Hash) } )
    @arguments_detail    = sort_arguments( @arguments.select { |arg| (arg["flag"] != "m") if arg.kind_of?(Hash) } )


    if success
      logger.info "Registration succeed"
      redirect_success
    else
      logger.info "Registration is not yet finished"
      respond_to do |format|
        format.html { render :action => "index" }
      end
    end
  end

end
