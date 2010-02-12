require 'yast/service_resource'
require 'firewall'

class FirewallController < ApplicationController

  CGI_PREFIX="firewall"

  before_filter :login_required
  layout 'main'

  init_gettext "yast_webclient_firewall"

  def index
    @firewall    = Firewall.find :one
    @firewall.services.each do |s|
        s.css_class  = CGI_PREFIX+"-"+s.id.gsub(/^service:/,"service-")
        s.input_name = CGI_PREFIX+"_"+s.id
    end
    Rails.logger.debug @firewall.inspect
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
