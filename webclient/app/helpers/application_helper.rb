# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Generate the Save button and a Cancel link, with the common UI style.
  # If the form is used in a wizard, they are named Next and Back.
  # send_options applies to the submission button.
  #
  # Example:
  #   <%= form_send_buttons :disabled => write_disabled %>
  def form_send_buttons (send_options={})
    ret = Basesystem.new.load_from_session(session).first_step? ? "":(form_cancel_button+form_str_spacer)
    ret + form_next_button(send_options)
  end

  # query if basesystem is in process
  def basesystem_in_process?
    Basesystem.new.load_from_session(session).in_process?
  end

  def form_str_spacer
    _(' or ')
  end

  def header_spacer
    _(' - ')
  end

  ##
  # Generate a cancel link with common UI style.
  # links to /controlpanel by default, developer can override
  # @param [Hash] options options for a link_to Rails helper method
  # @return [String] html part representing a cancel
  def form_back_button (options={})
    form_label_back_button _("Back"), options
  end

  def form_cancel_button (options={})
    form_label_back_button _("Cancel"), options
  end

  def form_label_back_button( label, options = {})
    bs = Basesystem.new.load_from_session(session)
    if bs.completed?
       if ! (options[:action] || options[:controller]) then
           options[:controller] = "controlpanel"
       end
       link_to label, options
    else
      link_to _("Back"), :controller => "controlpanel", :action => "backstep"
    end
  end

  def form_next_button(send_options={})
    bs = Basesystem.new.load_from_session(session)
    label = _("Next")
    label = send_options[:label] || _("Save") if bs.completed?
    label = _("Finish") if bs.last_step?
    submit_tag label,send_options
  end
end

