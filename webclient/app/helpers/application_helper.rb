# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Generate the Save button and a Cancel link, with the common UI style.
  # If the form is used in a wizard, they are named Next and Back.
  # send_options applies to the submission button.
  #
  # Example:
  #   <%= form_send_buttons :disabled => write_disabled %>
  def form_send_buttons (send_options={})
        str_spacer = _(' or ')
        if session[:wizard_current].nil? or session[:wizard_current] == "FINISH"
          submit = submit_tag _("Save"),send_options
          back = link_to _("Cancel"), :controller => "controlpanel"
          return submit+str_spacer+back
        else
          back = link_to "Back", :controller => "controlpanel", :action => "backstep"
          nextb = submit_tag _("Next"),send_options
          return back+str_spacer+nextb
        end
  end
end

