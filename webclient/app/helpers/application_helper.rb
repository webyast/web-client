# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Generate the Save button and a Cancel link, with the common UI style.
  # If the form is used in a wizard, they are named Next and Back.
  # send_options applies to the submission button.
  #
  # Example:
  #   <%= form_send_buttons :disabled => write_disabled %>
  def form_send_buttons (send_options={})
    ret = Basesystem.first_step?(session)?"":(form_back_button+form_str_spacer)
    ret + form_next_button(send_options)
  end

  def form_str_spacer
    _(' or ')
  end

  def form_back_button
    if Basesystem.done? session 
      link_to _("Cancel"), :controller => "controlpanel"
    else
      link_to "Back", :controller => "controlpanel", :action => "backstep"
    end
  end

  def form_next_button(send_options={})
    label = _("Next")
    label = _("Save") if Basesystem.done?(session)
    label = _("Finish") if Basesystem.last_step?(session)
    submit_tag label,send_options
  end
end

