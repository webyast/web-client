require 'firewall'

class FirewallController < ApplicationController

  CGI_PREFIX="firewall_"

  before_filter :login_required
  layout 'main'

  init_gettext "yast_webclient_firewall"

  def index
    @cgi_prefix  = CGI_PREFIX
    @firewall    = Firewall.find :one
    @permissions = Firewall.permissions
  end

  def checkbox_true?(name)
    ! params[name].nil? && params[name] == "true"
  end

  def update
    fw = Firewall.find :one
    fw.use_firewall = checkbox_true? "use_firewall"
    fw.services.each do |service|
      service.allowed = checkbox_true? (CGI_PREFIX+service.id)
    end
    fw.save
    flash[:notice] = _('Firewall settings have been written.')
    redirect_success
  end
end
