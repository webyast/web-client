# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'open-uri'

class ApplicationController < ActionController::Base
  layout 'main'

  rescue_from Exception, :with => :exception_trap
  
  include AuthenticatedSystem

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

  def exception_trap(e)
    logger.error "***" + e.to_s

    # get the vendor settings
    begin
      settings_url = YaST::ServiceResource::Session.site.merge("/vendor_settings/bugzilla_url.json")
      @bug_url = ActiveSupport::JSON.decode(open(settings_url).read)
    rescue Exception => e
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
      render :partial => "shared/exception_trap", :locals => {:error => e} and return
      #render :text => "shit" and return
    end

    render :template => "shared/exception_trap", :locals => {:error => e}
    return
  end
  
  def ensure_login
    unless logged_in?
      flash[:notice] = "Please login to continue"
      redirect_to new_session_path
    end
  end

  def ensure_logout
    if logged_in?
      flash[:notice] = "You must logout before you can login"
      redirect_to root_url
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
