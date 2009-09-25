require 'yast/service_resource'


class CustomServiceController < ApplicationController
  before_filter :login_required
  layout 'main'
  include ProxyLoader

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_custom_services"  # textdomain, options(:charset, :content_type)


  def index
   _("test")
  end


end
