# To change this template, choose Tools | Templates
# and open the template in the editor.

module ErrorConstructor    
  def construct_error (error)

    error = error["error"]
    case error["type"]
    when "NO_PERM"
      return _("Permission %s is not granted for user %s") % [error["permission"], error["user"]]
    when "POLKIT"
      return _("Policy kit exception for user %s and permission %s (untranslated message): %s") % [error["user"], error["permission"], error["polkitout"]]
    when "NOT_LOGGED"
      return _("Noone is logged to rest service.")
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
