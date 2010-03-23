require 'firewall'

class FirewallController < ApplicationController

  CGI_PREFIX="firewall"

  before_filter :login_required
  layout 'main'

  init_gettext "yast_webclient_firewall"

private

  def checkbox_true?(name)
    params[name] == "true"
  end

public

  def index
    @cgi_prefix = CGI_PREFIX
    @firewall    = Firewall.find :one
    @firewall.fw_services.each do |s|
        s.css_class  = CGI_PREFIX+"-"+s.id.gsub(/^service:/,"service-")
        # do not use translated name of the service, use service id instead
        s.name       = s.id.gsub(/^service:/,"")
        s.input_name = CGI_PREFIX+"_"+s.id
    end
    @firewall.fw_services.sort! {|x,y| x.name <=> y.name}
    Rails.logger.debug @firewall.inspect
    @permissions = Firewall.permissions
  end

  def update
    fw = Firewall.find :one
    fw.use_firewall = checkbox_true? "use_firewall"
    fw.fw_services.each do |service|
      service.allowed = checkbox_true? (CGI_PREFIX+"_"+service.id)
    end
    fw.save
    flash[:notice] = _('Firewall settings have been written.')
    redirect_success
  end
end
