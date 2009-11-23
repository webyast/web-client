require 'yast/service_resource'

# = Registration controller
# Provides all functionality, that handles system registration.

class RegistrationController < ApplicationController
  before_filter :login_required
  layout 'main'
  include ProxyLoader

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

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_registration"  # textdomain, options(:charset, :content_type)


  public

  # Index handler. Loads information from backend and if success all required
  # fields is filled. In case of errors redirect to help page, main page or just
  # show flash with partial problem.
  def index
    return unless client_permissions

    @detail = action_name == "detail"

    unless @permissions[:statelessregister]
      flash[:warning] = _("No permissions for registration")
      redirect_to root_path
      return false
    end

    status = nil
    @guid = nil
    begin
      status = @client.find if @client
    rescue
      status = nil
    end

    if status && status.respond_to?('guid') then
      @guid = status.guid unless status.guid.blank?
      # flash[:error] = "YES we have a GUI: #{status.guid}"
    else
      begin
        register = @client.new( {:arguments=>nil,
                                :options=>@options} )
        register.save
      rescue ActiveResource::ClientError => e
        error = Hash.from_xml(e.response.body)["registration"]
        if error && error["status"] == "missinginfo" && !error["missingarguments"].blank?
          logger.debug "missing arguments #{error["missingarguments"].inspect}"
          @arguments = error["missingarguments"].sort {|a,b| a["name"] <=> b["name"] } #in order to show it in an unique order
        else
          logger.error "error while getting arguments: #{error.inspect}"
          # keep the old message for the translation, in case we need it later
          old_error_msg = _("Arguments for registration cannot be evaluated.")
          flash[:error] = _("An error occurred during registration. Please try again.")
          redirect_to root_path
          return false
        end
      end
    end
  end

  def detail
    # different action but same semantic as in update
    update
  end

  # Calling the register over the service
  def update
    return unless client_permissions

    @detail = action_name == "detail"

    unless @permissions[:statelessregister]
      flash[:warning] = _("No permissions for registration")
      redirect_to root_path
      return false
    end
    params.each {| key, value | 
      if key.starts_with? "registration_arg,"
        argument = Hash.new
        argument["name"] = key[17, key.size-17]
        argument["value"] = value
        @arguments << argument
      end
    }

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
      if @changed_services && @changed_services.kind_of?(Array) then
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
        flash[:error] = _("Error occured while connecting to registration server.")
      end
    end  
    @arguments.sort! {|a,b| a["name"] <=> b["name"] } #in order to show it in an unique order

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
