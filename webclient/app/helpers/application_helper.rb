# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Generate the Save button and a Cancel link, with the common UI style.
  # If the form is used in a wizard, they are named Next and Back.
  # send_options applies to the submission button.
  #
  # Example:
  #   <%= form_send_buttons :disabled => write_disabled %>
  def form_send_buttons (send_options={})
    form_back_button + form_str_spacer + form_next_button(send_options)
  end

  def form_str_spacer
    _(' or ')
  end

  def form_back_button
    if session[:wizard_current].nil? or session[:wizard_current] == "FINISH"
      link_to _("Cancel"), :controller => "controlpanel"
    else
      link_to "Back", :controller => "controlpanel", :action => "backstep"
    end
  end

  def form_next_button(send_options={})
    if session[:wizard_current].nil? or session[:wizard_current] == "FINISH"
      submit_tag _("Save"),send_options
    else
      submit_tag _("Next"),send_options
    end
  end
end

