# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout 'main'

  include AuthenticatedSystem

  begin
    require 'gettext'
  rescue Exception => e
    $stderr.puts "rails-gettext not found!"
    exit
  end

  helper :all # include all helpers, all the time
  
  def initialize
    super
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


  def set_permissions(controller_name)
    if (session[:controllers] &&
        session[:controllers][controller_name])
       if session[:controllers][controller_name].write_permission
          @write_permission = nil
       else
          @write_permission = "disabled"
       end 
       if session[:controllers][controller_name].read_permission
          @read_permission = nil
       else
          @read_permission = "disabled"
       end 
       if session[:controllers][controller_name].delete_permission
          @delete_permission = nil
       else
          @delete_permission = "disabled"
       end 
       if session[:controllers][controller_name].new_permission
          @new_permission = nil
       else
          @new_permission = "disabled"
       end 
       if session[:controllers][controller_name].execute_permission
          @execute_permission = nil
       else
          @execute_permission = "disabled"
       end 
       if session[:controllers][controller_name].install_permission
          @install_permission = nil
       else
          @install_permission = "disabled"
       end 
    else
       @execute_permission = "disabled"
       @new_permission = "disabled"
       @delete_permission = "disabled"
       @read_permission = "disabled"
       @write_permission = "disabled"
       @install_permission = "disabled"
    end
  end


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'b1aeb693a1ee49ab70c6b6bf514963a3'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  filter_parameter_logging :password
end
