#--
# Webyast Webclient framework
#
# Copyright (C) 2009, 2010 Novell, Inc. 
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation. 
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details. 
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'open-uri'
require 'client_exception'
require 'action_controller/base'
require 'url_rewriter' #monkey patch for url_for with port

class ApplicationController < ActionController::Base
  layout 'main'  

protected
  def redirect_success
    logger.debug session.inspect
    if Basesystem.installed? && Basesystem.new.load_from_session(session).in_process?
      logger.debug "wizard redirect DONE"
      redirect_to :controller => "controlpanel", :action => "nextstep", :done => self.controller_name
    else
      logger.debug "Success non-wizard redirect"
      redirect_to :controller => "controlpanel", :action => "index"
    end
  end

  #catch webservice errors
  rescue_from Exception, :with => :exception_trap
  rescue_from ActiveResource::UnauthorizedAccess do #lazy load of activeresource exception
    flash[:error] = _("Session timeout");
    if request.xhr?
      render :text => flash[:error], :status => 401
    else
      redirect_to '/logout'
    end
  end

  # helper to add details show link with details content as parameter
  # Main usage is for flash message
  #
  # === usage ===
  # flash[:error] = "Fatal error."+details("really interesting details")
  def details(message, options={})
    ret = "<br><a href=\"#\" onClick=\"$('.details',this.parentNode).css('display','block');\"><small>#{_('details')}</small></a>
            <pre class=\"details\" style=\"display:none\"> #{CGI.escapeHTML message } </pre>"
    ret
  end
  
  include AuthenticatedSystem
  include ErrorConstructor
#hide actions because our routing table has automatic action mapping
  hide_action :construct_error

  require 'gettext_rails'
public
  helper :all # include all helpers, all the time

protected

  def initialize
    super
  end

  before_filter :set_session_login
private
  # The information is kept in YaST::ServiceResource::Session, a module
  # that is shared between all connected clients, leading to bnc#542143.
  # To work around it, we reset the data from the browser session
  # in a global before_filter.
  def set_session_login
    if logged_in? && session[:host]
      YaST::ServiceResource::Session.login = session[:user]
      YaST::ServiceResource::Session.auth_token = session[:auth_token]
      YaST::ServiceResource::Session.site = Host.find(session[:host]).url
    end
  end

  def exception_trap(error)
    logger.error "***" + error.to_s
    logger.error error.backtrace.join "\n"

    e = ClientException.new(error)
    logger.error "Exception started at the server side" if e.backend_exception?
    
#handle insufficient permissions, especially useful for read permissions,
#because you cannot open module for which you don't have read permissions.
# if it appear during save, then it is module bug, as it cannot allow it
    if e.backend_exception_type == "NO_PERM"
      flash[:error] = _("Operation is forbidden. If you have to do it, please contact system administrator")+
                          details(e.message) #already localized from error constructor RORSCAN_ITL
      if  request.xhr?
        render :text => "<div>#{flash[:error]}</div>", :status => 403
      else
        redirect_to :controller => :controlpanel
      end
      return
    end
    
    # for ajax request render a different template, much less verbose
    if request.xhr?
      logger.error "Error during ajax request"
      render :status => 500, :partial => "shared/exception_trap", :locals => {:error => e} and return
    end

    #disabled cookies result in ActionController::InvalidAuthenticityToken (bnc#637361)
    case e.origin_exception
    when ActionController::InvalidAuthenticityToken
      render :status => 500, :template => "shared/cookies_disabled"
    else
      render :status => 500, :template => "shared/exception_trap", :locals => {:error => e}
    end

    return
  end
  
  def self.bug_url
    begin
      VendorSetting.site = YaST::ServiceResource::Session.site.to_s
      url = VendorSetting.find(:all,:from => "/vendor_settings.xml").detect{|v| v.name == "bug_url"}.value
      return url unless url.blank?
    rescue Exception => vendor_excp
      # there was a problem or the setting does not exist
      # Here we should handle this always as an error
      # the service should return a sane default if the
      # url is not configured
      logger.warn "Can't get vendor bug reporting url, Using Novell. Exception: #{vendor_excp.inspect}"
    end
    #fallback if bugurl is not defined
    return "https://bugzilla.novell.com/enter_bug.cgi?product=WebYaST&format=guided"
  end

protected
  def ensure_login
    unless logged_in?
      flash[:notice] = _("Please login to continue")
      redirect_to :controller => "session", :action => "new", :hostid => "localhost" #redirect by default to locahost appliance (bnc#602807)
    end
  end

  def ensure_logout
    if logged_in?
      flash[:notice] = _("You must logout before you can login")
      redirect_to root_url
    end
  end

protected
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
        locale_path = ""
        #searching in RAILS_ROOT
        mo_files = Dir.glob(File.join(RAILS_ROOT, "**", "#{domainname}.mo"))
        if mo_files.size > 0
          locale_path = File.dirname(File.dirname(File.dirname(mo_files.first)))
        else
          # trying plugin directory in the git 
          mo_files = Dir.glob(File.join(RAILS_ROOT, "..", "**", "#{domainname}.mo"))
          locale_path = File.dirname(File.dirname(File.dirname(mo_files.first))) if mo_files.size > 0
        end
        unless locale_path.blank?
          logger.info "Loading standard textdomain #{domainname} from #{locale_path}"
          opt = {:locale_path => locale_path}.merge(options)
          ActionController::Base.init_gettext(domainname, opt)
        else
          logger.error "Cannot find translation for #{domainname}"
        end
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
  init_gettext "webyast-base-ui"  # textdomain, options(:charset, :content_type)
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
  protect_from_forgery # :secret => 'b1aeb693a1ee49ab70c6b6bf514963a3' RORSCAN_ITL

  # See ActionController::Base for details
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").
  filter_parameter_logging :password # RORSCAN_ITL

  # Translation mapping for ActiveResource validation errors
  def error_mapping
    # TODO: is it complete?
    # ActiveRecord::Errors.default_error_messages defines more messages
    # but it seems that they cannot be used with YaST model...
    {
      :blank => _("can't be blank"),
      :inclusion => _("is out of allowed values"),
      :empty => _("can't be empty"),
      :invalid => _("is invalid")
    }
  end

  private :error_mapping

  # Create human readable error meesages from passed ActiveResource object
  # This error message can be used either in flash or in a view
  # Parameters:
  #   obj => ActiveResource object
  #   mapping => custom mapping of attribute name => translatable description,
  #      e.g. { :name => _('Name')}
  #      the mapping should match the labels used in the form
  #   header => optional header
  #
  def generate_error_messages obj, mapping = {}, header = _('Invalid parameters:')
    return '' if obj.errors.size == 0

    emapping = error_mapping
    ret = ''

    obj.errors.each {|attr, msg|
      attrib_name = mapping[attr.to_sym] || attr
      err_msg = emapping[msg.to_sym] || ''

      ret += "<li>#{ERB::Util.html_escape attrib_name} #{ERB::Util.html_escape err_msg}</li>"
    }

    "<p>#{ERB::Util.html_escape header}</p><ul>#{ret}</ul>"
  end
end
