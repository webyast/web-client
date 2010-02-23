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
                '___getittranslated1' => _("Registration code"),
                '___getittranslated2' => _("Hostname"),
                '___getittranslated3' => _("Device name"),
                '___getittranslated4' => _("Appliance name")   }
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

  def translate_argument_key(key)
    return '-unknown-' unless key
    return @trans[key] if ( @trans.kind_of?(Hash) && @trans[key] )
    key
  end

  def sort_arguments(args)
    return Array.new unless args.kind_of?(Array)
    args.collect! do |arg|
      arg['description'] = translate_argument_key( arg.kind_of?(Hash) ? arg['name'] : nil )
      arg
    end
    # sort by names alphabetically and by flags reverse (move mandatory fields up)
    args.sort! { |a,b|  (b['flag'] || 'z') + a['name'] <=> (a['flag'] || 'z') + b['name'] }
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

  def server_error_flash(msg)
    error_old = _("Error occured while connecting to registration server.")
    error_line1 = _("<b>Registration did not finish.</b>")
    error_line2 = ( msg || "" ) + " " + _("This may be a temporary issue.")
    error_line3 = _("Please try to register again later.")
    return error_line1 + "<br />" + error_line2 + "<br />" + error_line3
  end

  public

  # Index handler. Loads information from backend and if success all required
  # fields are filled. In case of errors redirect to help page, main page or just
  # show flash with partial problem.
  def index
    return unless client_permissions

    unless @permissions[:statelessregister]
      flash[:warning] = _("No permissions for registration")
      redirect_to root_path
      return false
    end

    if !client_guid
      @arguments = []
      @nexttarget = 'update'
      update
    else
      @showstatus = true
    end

  end

  def done
    # just redirect to the appropriate next target
    redirect_success
    return
  end

  def detail
    # different action but same semantic as in update
    @detail = true
    @nexttarget = 'detail'
    update
  end

  def reregister
    # provide a way to force a new registration, even if system is already registered
    @reregister = true
    @nexttarget = 'reregister'
    update
  end

  # Calling registration over the service
  def update
    return unless client_permissions

    unless @permissions[:statelessregister]
      flash[:warning] = _("No permissions for registration")
      redirect_to root_path
      return false
    end

    # redirect in case of interrupted basesetup
    if client_guid && !@reregister && !@detail
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
        ##FIXME - also care about repos!!
        # display warning message if no repos are added/changed during registration (bnc#558854)
        flash[:warning] = _("<p><b>Repositories were not modified during the registration process.</b></p><p>It is likely that an incorrect registration code was used. If this is the case, please attempt the registration process again to get an update repository.</p><p>Please make sure that this system has an update repository configured, otherwise it will not receive updates.</p>")
        # flash[:warning] = _("No repositories were added or changed during the registration process (maybe due to a wrong registration code). If this system already has an update repository everything is fine. But without an update repository this system will not receive any updates. You may run the registration module again.")
      end

      # inform about added repositories
      if @changed_repositories && @changed_repositories.kind_of?(Array) then
        flash[:notice] += "<ul>"
        @changed_repositories.each do |r|
          if r.respond_to?(:name) && r.name && r.respond_to?(:status) && r.status == 'added' then
            flash[:notice] += "<li>" + _("Repository added:") + " #{r.name}</li>"
          end
        end
        flash[:notice] += "</ul>"
      end

    # rescue ActiveResource::ServerError => e
    #  logger.error "500500500500500500500500500500500"
    #  logger.error e.inspect
    #  flash[:error] = "500500500500500500500500500500500"
    #rescue ActiveResource::ResourceNotFound => e
    #  logger.error "404404404404404404404404404404404"
    #  logger.error e.inspect
    #  flash[:error] = "404404404404404404404404404404404"
    rescue ActiveResource::ClientError => e
      error = Hash.from_xml(e.response.body)["registration"]
      if error && error["status"] == "missinginfo" && !error["missingarguments"].blank?
        logger.debug "missing arguments #{error["missingarguments"].inspect}"
        #compare this with already existing arguments
        missed_args = error["missingarguments"]
        @arguments.collect! {|argument|
          missed_args.each {|missed_arg|
            if missed_arg["name"] == argument["name"]
              argument["error"] = true #flag error for already existing argument
              argument["flag"] = missed_arg["flag"]
              argument["kind"] = missed_arg["kind"]
              missed_args.reject! {|del_arg| del_arg["name"] == argument["name"] }
              break
            end
          }
          argument
        }
        #add the rest of missed arguments
        missed_args.collect! {|missed_arg|
          missed_arg["error"] = true
          missed_arg
        }
        @arguments.concat(missed_args)
        flash[:error] = _("Please fill out missing entries.")
      else
        logger.error "error while registration: #{error.inspect}"
        flash[:error] = server_error_flash _("The registration server returned invalid data.")
        # success: allow users to skip registration in case of an error (bnc#578684) (bnc#579463)
        success = true
      end
    rescue Exception => e
      flash[:error] = server_error_flash _("The registration server was not reachable due to network or registration server problems.")
      success = true
    end
    @arguments = sort_arguments( @arguments ) #in order to show it in an unique order

    if success
      logger.info "registration succeed"
      redirect_success
    else
      logger.info "additional steps required"
      respond_to do |format|
        format.html { render :action => "index" }
      end
    end
  end

end
