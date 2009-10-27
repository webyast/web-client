# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'open-uri'

class ApplicationController < ActionController::Base
  layout 'main'  

  def redirect_success
    if session[:wizard_current] and session[:wizard_current] != "FINISH"
      logger.debug "wizard redirect DONE"
      redirect_to :controller => "controlpanel", :action => "nextstep"
    else
      logger.debug "Success non-wizard redirect"
      redirect_to :action => :index
    end
  end

  #catch webservice errors
  rescue_from Exception, :with => :exception_trap
  rescue_from ActiveResource::ServerError, :with => :backendexception_trap
  

  
  include AuthenticatedSystem
  include ErrorConstructor

  begin
    require 'gettext_rails'
  rescue Exception => e
    $stderr.puts "gettext_rails not found!"
    exit
  end

  helper :all # include all helpers, all the time

  def initialize
    super
  end

  
  def backendexception_trap(e)
    logger.debug "Backend exception trap"
    logger.debug e.response.body.inspect
    if e.response.code =~ /.*503.*/
      logger.debug "got backend Exception"
      error = Hash.from_xml e.response.body
      eulaexception_trap and return if error["error"]["type"] == "EULA_NOT_ACCEPTED"
      # construct an exception from what we have
      err_msg = construct_error(error)
      e = Exception.new
      e.message = err_msg
      # add the backtrace to the exception
      #e.set_backtrace(error["error"]["backtrace"].split("\n"))
      if request.xhr?
        logger.error "Backend error during ajax request"
        render :status => 503, :partial => "shared/exception_trap", :locals => {:error => e} and return
      else
        render :status => 503, :template => "shared/backendexception_trap", :locals => {:error => err_msg}
      end
    else
      exception_trap(e)
    end
  end

  def eulaexception_trap
    flash[:error] = _("You must accept all EULAs before using this product!")
    if ActionController::Routing.possible_controllers.include?("eulas") then
      redirect_to :controller => :eulas, :action => :next
    else
      render :status => 501, :text => _("Cannot redirect to EULA. Make sure yast2-webclient-eulas package is installed")
    end
    true
  end

  def exception_trap(e)
    logger.error "***" + e.to_s
    logger.error e.backtrace.join "\n"
    
    # get the vendor settings
    begin
      settings_url = YaST::ServiceResource::Session.site.merge("/vendor_settings/bugzilla_url.json")
      @bug_url = ActiveSupport::JSON.decode(open(settings_url).read)
    rescue Exception => vendor_excp
      @bug_url = "https://bugzilla.novell.com/enter_bug.cgi?classification=7340&product=openSUSE+11.2&submit=Use+This+Product&component=WebYaST&format=guided"
      # there was a problem or the setting does not exist
      # Here we should handle this always as an error
      # the service should return a sane default if the
      # url is not configured
      logger.warn "Can't get vendor bug reporting url, Using Novell"
    end
    
    # for ajax request render a different template, much less verbose
    if request.xhr?
      logger.error "Error during ajax request"
      render :status => 500, :partial => "shared/exception_trap", :locals => {:error => e} and return
      #render :text => "shit" and return
    end

    case e
    when ActionController::InvalidAuthenticityToken
      render :status => 500, :template => "shared/cookies_disabled"
    else
      render :status => 500, :template => "shared/exception_trap", :locals => {:error => e}
    end

    return
  end
  
  def ensure_login
    unless logged_in?
      flash[:notice] = _("Please login to continue")
      redirect_to new_session_path
    end
  end

  def ensure_logout
    if logged_in?
      flash[:notice] = _("You must logout before you can login")
      redirect_to root_url
    end
  end

  def self.init_gettext(domainname, options = {})
    locale_path = options[:locale_path]
    unless locale_path
      #If path of the translation has not been set we are trying to load
      #vendor specific translations too
      if Dir.glob(File.join("**", "public", "**", "#{domainname}.mo")).size > 0
        vendor_text_path = "public/vendor/text/locale"
        locale_path = File.join(RAILS_ROOT, vendor_text_path)
        opt = {:locale_path => locale_path}.merge(options)
        logger.info "Loading textdomain #{domainname} from #{vendor_text_path}"
        ActionController::Base.init_gettext(domainname, opt)
      else
        #load default no vendor translation available
        logger.info "Loading standard textdomain #{domainname}"
        ActionController::Base.init_gettext(domainname, options)
      end
    else
      #load default if the path has been given
      logger.info "Loading textdomain #{domainname} from #{locale_path}"
      ActionController::Base.init_gettext(domainname, options)
    end
  end

  # Initialize GetText and Content-Type.
  # You need to call this once a request from WWW browser.
  # You can select the scope of the textdomain.
  # 1. If you call init_gettext in ApplicationControler,
  #    The textdomain apply whole your application.
  # 2. If you call init_gettext in each controllers
  #    (In this sample, blog_controller.rb is applicable)
  #    The textdomains are applied to each controllers/views.
  init_gettext "yast_webclient"  # textdomain, options(:charset, :content_type)
  I18n.supported_locales = Dir[ File.join(RAILS_ROOT, 'locale/*') ].collect{|v| File.basename(v)}

=begin
  # You can set callback methods. These methods are called on the each WWW request.
  def before_init_gettext(cgi)
    p "before_init_gettext"
  end
  def after_init_gettext(cgi)
    p "after_init_gettext"
  end
=end


=begin
  # you can redefined the title/explanation of the top of the error message.
  ActionView::Helpers::ActiveRecordHelper::L10n.set_error_message_title(N_("An error is occured on %{record}"), N_("%{num} errors are occured on %{record}"))
  ActionView::Helpers::ActiveRecordHelper::L10n.set_error_message_explanation(N_("The error is:"), N_("The errors are:"))
=end

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'b1aeb693a1ee49ab70c6b6bf514963a3'

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  filter_parameter_logging :password
end
