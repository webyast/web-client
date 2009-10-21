# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
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

