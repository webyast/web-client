require 'gettext'

# from the error data (a hash created from
# the error response body xml), return a
# translation if the error type is known
module ErrorConstructor
  include GetText
  
  def construct_error(error)
    error = error["error"]
    case error["type"]
    when "SERVICE_NOT_AVAILABLE"
      return _("Service %s is not available in the target machine") % [error["service"]]
    when "SERVICE_NOT_RUNNING"
      return _("Service %s is not running on the target machine") % [error["service"]]
    when "NO_PERM"
      return _("Permission %s is not granted for user %s") % [error["permission"], error["user"]]
    when "POLKIT"
      return _("Policy kit exception for user %s and permission %s (untranslated message): %s") % [error["user"], error["permission"], error["polkitout"]]
    when "NOT_LOGGED"
      return _("A user is no longer logged to target machine. Please log in again.")
    when "BADFILE"
      return _("Target system is not consistent: Missing or corrupted file %s") %error["file"]
    when "NTP_ERROR"
      problem = error["output"]
      if error["output"]=="NOSERVERS" #special value indicates that there is no predefined ntp server
        problem = _("There is no predefined ntp server at /etc/sysconfig/network/config - NETCONFIG_NTP_STATIC_SERVERS")
      end
      return _("Error occured during ntp synchronization: %s") %problem
    when "ADMINISTRATOR_ERROR"
      problem = error["output"]
      return _("Error while saving administrator settings: %s") %problem
    else
      RAILS_DEFAULT_LOGGER.warn "Untranslated message for exception #{error["type"]}"
      return error["description"]
    end
  end
end
