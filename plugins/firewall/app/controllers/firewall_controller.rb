require 'yast/service_resource'
require 'firewall'

class FirewallController < ApplicationController
  before_filter :login_required
  layout 'main'

  init_gettext "yast_webclient_firewall"

  def index
    flash[:error] = "These data are only a sample, they do not correspond to machine settings!"
    flash[:notice] = "IDEA 1: Do not use 'Use firewall' checkbox. Firewall will be used implicitely unless all services are allowed."
    flash[:warning] = "IDEA 2: Can be combined with services module by adding 'allowed' checkbox to each service. Pros : simpler interface, Cons : no visible firewall icon in control panel (it will be harder to market firewall to customer). "
    @firewall    = Firewall.find :one
    @permissions = Firewall.permissions
  end
end
