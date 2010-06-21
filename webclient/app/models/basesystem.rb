#--
# Webyast Webclient framework
#
# Copyright (C) 2009, 2010 Novell, Inc. 
#   This library is free software; you can redistribute it and/or modify
# it only under the terms of version 2.1 of the GNU Lesser General Public
# License as published by the Free Software Foundation. 
#
#   This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more 
# details. 
#
#   You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software 
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#++

class Basesystem < ActiveResource::Base
  extend YastModel::Base
  model_interface :'org.opensuse.yast.modules.basesystem'

  def self.installed?
    YastModel::Resource.interfaces_available? :'org.opensuse.yast.modules.basesystem'
  end

  def load_from_session(session)
    @session = session
    @steps = @session[:wizard_steps].try(:split,",")
    self
  end

  def initialized
    !(current.blank?)
  end

  # find basesystem status of backend and properly set session for that
  #
  # Note:: See first argument, which is additional to ordinary find method
  def self.find(session,*args)
    bs = super :one
    if bs.steps.empty? or bs.finish
      session[:wizard_current] = FINISH_STEP
    else
      Rails.logger.debug "Basesystem steps: #{bs.steps.inspect}"
      decoded_steps = bs.steps.collect { |step| step.respond_to?(:action) ? "#{step.controller}:#{step.action}" : "#{step.controller}"}
      session[:wizard_steps] = decoded_steps.join(",")
      session[:wizard_current] =
        decoded_steps.find(lambda{decoded_steps.first}) do |s|
          s.include? bs.done
        end
    end
    bs.load_from_session session
    bs
  end
  
  # return:: controller which should be next in basesystem sequence
  # or controlpanel if basesystem is finished
  # 
  # require to be basesystem initialized otherwise throw exception
  def next_step
    if current == @steps.last
      self.current_step = FINISH_STEP
      load(:finish => true, :steps => []) #persistent store, that basesystem finish
      save #TODO check return value
      return :controller => "controlpanel"
    else
      self.current_step = @steps[@steps.index(current)+1]
      load(:finish => false,  :steps => [], :done => self.current_step[:controller]) #store advantage in setup
      save #TODO check return value
      ret = redirect_hash
      raise "Invalid configuration. Missing controller required in First boot sequence. 
        Possible typo or plugin is not installed." unless 
          ActionController::Routing.possible_controllers.include? ret[:controller]
      return ret
    end
  end

  def current_step
    redirect_hash
  end

  def back_step
    self.current_step = @steps[@steps.index(current)-1] unless first_step?
    redirect_hash
  end

  # Gets steps which follow after current one
  # return:: array of hashes with keys :controller and :action, if basesystem finish return empty array
  def following_steps
    return [] if (!initialized || completed?)
    ret = @steps.slice @steps.index(current)+1,@steps.size
    ret = ret.collect { |step|
      arr = step.split(":")
      { :controller => arr[0], :action => arr[1]||"index"}
    }
  end

  def first_step?
    !(@steps.blank?) && current == @steps.first
  end

  def last_step?
    !(@steps.blank?) && current == @steps.last
  end

  def completed?
    current == FINISH_STEP
  end

  def in_process?
    @steps && !(completed?)
  end

  private
  FINISH_STEP = "FINISH"

  def current_step=(val)
    @session[:wizard_current] = val
  end

  def redirect_hash
    arr = current.split(":")
    { :controller => arr[0], :action => arr[1]||"index"}
  end

  def current
    @session[:wizard_current]
  end
end
