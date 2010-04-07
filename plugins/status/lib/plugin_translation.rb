require 'gettext'
require 'scanf'

# This is a workaround only until plugin messages
# will be translated on the service side.

module PluginTranslation
  include GetText

  def extract_params(source, pattern)
     source.scanf(pattern)
  end
  
  def translate_plugin_message(plugin)
    ret = nil
    if plugin.is_a? Array
      ret = []
      plugin.each {|plug|
        ret << translate_plugin_message(plug)
      }
    else
      ret = plugin
      case plugin.message_id
      when "MISSING_REGISTRATION"
        ret.short_description = _("Registration is missing")
        ret.long_description = _("Please register your system in order to get updates.")
        ret.confirmation_label = _("register")
      when "MAIL_SENT"
        ret.short_description = _("Mail configuration test not confirmed")
        translated = _("During Mail configuration, test mail was sent to %s . Was the mail delivered to this address?<br> If so, confirm it by pressing the button. Otherwise, check your mail confiuration again.") #Need this double for generating the pot files.
        pattern = "During Mail configuration, test mail was sent to %s . Was the mail delivered to this address?<br> If so, confirm it by pressing the button. Otherwise, check your mail confiuration again."
        ret.long_description = translated % extract_params(plugin.long_description,pattern)
        ret.details = plugin.details.blank? ? "" : _("It was not possible to retrieve full hostname of the machine. If the mail could not be delivered, consult the network and/or mail configuration with your network administrator.")
        ret.confirmation_label = _("Test mail received")
      else
        RAILS_DEFAULT_LOGGER.warn "Not known message-id #{plugin.message_id}"
      end
    end
    return ret
  end
end
