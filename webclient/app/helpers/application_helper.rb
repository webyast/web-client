# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def form_send_buttons (send_options={})
        if session[:wizard_current].nil? or session[:wizard_current] == "FINISH"
          submit = submit_tag _("Save"),send_options
          back = link_to _("Cancel"), :back
          return submit+back
        else
          back = link_to "Back", :controller => "controlpanel", :action => "backstep"
          nextb = link_to submit_tag _("Next"),send_options
          return back+nextb
        end
  end
end

