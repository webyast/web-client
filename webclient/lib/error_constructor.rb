# To change this template, choose Tools | Templates
# and open the template in the editor.

module ErrorConstructor    
  def construct_error (error)

    error = error["error"]
    case error["type"]
    when "NO_PERM"
      return _("Permission #{error["permission"]} is not granted for user #{error["user"]}")
    when "POLKIT"
      return _("Policy kit exception for user #{error["user"]} and permission #{error["permission"]} (untranslated message): #{error["message"]}")
    when "NOT_LOGGED"
      return _("Noone is logged to rest service.")
    when "BADFILE"
      return _("Target system is not consistent: Missing or corrupted file #{error["file"]}")
    end
  end
end
