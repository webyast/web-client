#--
# Copyright (c) 2009-2010 Novell, Inc.
# 
# All Rights Reserved.
# 
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License
# as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
# 
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#++

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
        translated = _("While configuring mail, a test mail was sent to %s . Was the mail delivered to this address?<br>If so, confirm it by pressing the button. Otherwise check your mail configuration again.") #Need this double for generating the pot files.
        pattern = "While configuring mail, a test mail was sent to %s . Was the mail delivered to this address?<br>If so, confirm it by pressing the button. Otherwise check your mail configuration again."
        ret.long_description = translated % extract_params(plugin.long_description,pattern)
        ret.details = plugin.details.blank? ? "" : _("It was not possible to retrieve the full hostname of the machine. If the mail could not be delivered, consult the network and/or mail configuration with your network administrator.")
        ret.confirmation_label = _("Test mail received")
      else
        RAILS_DEFAULT_LOGGER.warn "Not known message-id #{plugin.message_id}"
      end
    end
    return ret
  end
end
