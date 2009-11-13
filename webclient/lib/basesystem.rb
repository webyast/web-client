module Basesystem
  # Constant that signalizes, that all steps from base system setup are done
  FINAL_STEP = "FINISH"
  def Basesystem.done?(session)
    session[:wizard_current] && session[:wizard_current] == FINAL_STEP
  end

  def Basesystem.in_process?(session)
    session.has_key?(:wizard_steps) && !done?(session)
  end

  def Basesystem.initialized?(session)
    session.has_key?(:wizard_current)
  end

  def Basesystem.set_finish(session)
      session[:wizard_current] = FINAL_STEP
      Rails.logger.debug "Wizard next step: DONE"
  end

  def Basesystem.next_step(session)
    Rails.logger.debug "Wizard next step: current one: #{session[:wizard_current]} - steps #{session[:wizard_steps]}"
    steps = session[:wizard_steps].split ","
    if (steps.last != session[:wizard_current])
      session[:wizard_current] = steps[steps.index(session[:wizard_current])+1]
      Rails.logger.debug "Wizard next step: next one #{session[:wizard_current]}"
    else
      set_finish session
    end
  end

  def Basesystem.current_target(session)
    arr = session[:wizard_current].split(":")
    ret = { :controller => arr[0], :action => arr[1]||"index"}
    Rails.logger.debug ret.inspect
    return ret
  end

  def Basesystem.back_step(session)
    steps = session[:wizard_steps].split ","
    if session[:wizard_current] != steps.first
      session[:wizard_current] = steps[steps.index(session[:wizard_current])-1]
    end
  end

  def Basesystem.first_step?(session)
    steps = session[:wizard_steps].split ","
    session[:wizard_current] == steps.first
  end

  def Basesystem.initialize(basesystem,session)
    if basesystem.steps.empty? or basesystem.finish
      session[:wizard_current] = FINAL_STEP
    else
      # we got some steps from backend, base system setup is not over and 
      # no sign of progress in session variables => restart base system setup
      Rails.logger.debug "Basesystem steps: #{basesystem.steps.inspect}"
      decoded_steps = basesystem.steps.collect { |step| step.action ? "#{step.controller}:#{step.action}" : "#{step.controller}"  }
      session[:wizard_steps] = decoded_steps.join(",")
      session[:wizard_current] = decoded_steps.first
    end
  end
end
