require 'yast/service_resource'

# = Registration controller
# Provides all functionality, that handles system registration.

class RegistrationController < ApplicationController
  before_filter :login_required
  layout 'main'

  private
  def client_permissions
    @client = YaST::ServiceResource.proxy_for('org.opensuse.yast.modules.registration.registration')
    unless @client
      flash[:notice] = _("Invalid session, please login again.")
      redirect_to( logout_path ) and return
    end
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

    unless @permissions[:statelessregister]
      flash[:warning] = _("No permissions for registration")
      redirect_to root_path
      return false
    end
    register = @client.new({:arguments=>nil, 
                           :options=>@options})
    begin
      register.save
    rescue ActiveResource::ClientError => e
      error = Hash.from_xml(e.response.body)["registration"]
      if error["status"] == "missinginfo" && !error["missingarguments"].blank?
        logger.debug "missing arguments #{error["missingarguments"].inspect}"
        @arguments = error["missingarguments"].sort {|a,b| a["name"] <=> b["name"] } #in order to show it in an unique order
      else
        logger.error "error while getting arguments: #{error.inspect}"  
        flash[:error] = _("Arguments for registration cannot be evaluated.")
        redirect_to root_path
        return false
      end
    end        
  end

  # Calling the register over the service
  def update
    return unless client_permissions

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
    begin
      register = @client.create({:arguments=>@arguments, 
                                :options=>@options})
      logger.debug "registration finished: #{register.to_xml}"
      @changed_repositories = register.changedrepos if register.respond_to? :changedrepos
      flash[:notice] = _("Registration finished successfully.")
    rescue ActiveResource::ClientError => e
      error = Hash.from_xml(e.response.body)["registration"]
      if error["status"] == "missinginfo" && !error["missingarguments"].blank?
        logger.debug "missing arguments #{error["missingarguments"].inspect}"
        #compare this with already existing arguments
        missed_args = error["missingarguments"]
        @arguments.collect! {|argument|
          missed_args.each {|missed_arg|
            if missed_arg["name"] == argument["name"]
              argument["error"] = true #flag error for already existing argument
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

    respond_to do |format|
      format.html { render :action => "index" }
    end      
  end

end
