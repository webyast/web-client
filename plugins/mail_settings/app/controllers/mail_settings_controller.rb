require 'yast/service_resource'

class MailSettingsController < ApplicationController
  before_filter :login_required
  include ProxyLoader

  private

  # Initialize GetText and Content-Type.
  init_gettext "yast_webclient_mailsettings"  # textdomain, options(:charset, :content_type)

  public

  def index
    @mail_settings	= load_proxy 'org.opensuse.yast.modules.yapi.mailsettings'
    return unless @mail_settings
    @mail_settings.confirm_password	= ""
  end

  # PUT
  def update
    @mail_settings	= load_proxy 'org.opensuse.yast.modules.yapi.mailsettings'
    return unless @mail_settings
    redirect_to :action => "index"
  end

end

# vim: ft=ruby
