require File.dirname(__FILE__) + '/../test_helper'

class BasesystemTest < ActiveSupport::TestCase

  class ActionMockup
    attr_reader :controller, :action

    def initialize(controller, action = nil)
      @controller = controller
      @action = action
    end
  end

  class BasesystemMockup
    attr_accessor :steps, :finish
    STEPS = [ ActionMockup.new("timezone"),ActionMockup.new("language","show")]

    def initialize
      @steps = STEPS
      @finish = false
    end
  end

  def setup
    @basesystem = BasesystemMockup.new
  end

  def test_initialize
    session = {}
    Basesystem.initialize(@basesystem,session)
    assert !Basesystem.done?(session)
    assert Basesystem.first_step?(session)
    result = {:controller => "timezone", :action => "index"}
    assert_equal  result,Basesystem.current_target(session)
    Basesystem.next_step session
    result = {:controller => "language", :action => "show"}
    assert_equal  result,Basesystem.current_target(session)
    Basesystem.back_step session
    result = {:controller => "timezone", :action => "index"}
    assert_equal  result,Basesystem.current_target(session)
    Basesystem.next_step session
    Basesystem.next_step session
    assert Basesystem.done?(session)
  end

  def test_empty_basesystem
    session = {}
    @basesystem.steps = []
    Basesystem.initialize(@basesystem,session)
    assert Basesystem.done?(session)
  end

  def test_finished_basesystem
    session = {}
    @basesystem.finish = true
    Basesystem.initialize(@basesystem,session)
    assert Basesystem.done?(session)
  end

end
