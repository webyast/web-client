require File.dirname(__FILE__) + '/../test_helper'
require 'yast_mock'

class BasesystemTest < ActiveSupport::TestCase

  def setup
    response_bs = load_xml_response "basesystem.xml"
    request_bs = load_xml_response "basesystem-response.xml"
    ActiveResource::HttpMock.set_authentication
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      # this is inadequate, :singular is per resource,
      # and does NOT depend on :policy
      # see yast-rest-service/plugins/network/config/resources/*
      mock.resources :"org.opensuse.yast.modules.basesystem" => "/basesystem"
      mock.permissions "org.opensuse.yast.modules.basesystem", {}
      mock.get  "/basesystem.xml", header, response_bs, 200
      mock.post  "/basesystem.xml", header, request_bs, 200
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_initialize
    session = {}
    bs = Basesystem.find session
    assert !bs.completed?
    assert bs.first_step?
    result = {:controller => "systemtime", :action => "index"}
    assert_equal  result,bs.current_step
    result = {:controller => "language", :action => "cool_action"}
    assert_equal  result,bs.next_step
    result = {:controller => "systemtime", :action => "index"}
    assert_equal  result,bs.back_step
    bs.next_step
    assert bs.last_step?
    bs.next_step 
    assert bs.completed?
  end

  def test_load_from_session
    session = {:wizard_current => "systemtime", :wizard_steps => "systemtime" }
    bs = Basesystem.new.load_from_session session
    assert !bs.completed?
    assert bs.first_step?
    assert bs.last_step?
    bs.next_step 
    assert bs.completed?
  end
=begin create special response for it
  def test_empty_basesystem
    session = {}
    @basesystem.steps = []
    Basesystem.initialize(@basesystem,session)
    assert Basesystem.done?(session)
  end
=end

  def test_finished_basesystem
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
      response_bs = load_xml_response "basesystem-complete.xml"
      mock.resources :"org.opensuse.yast.modules.basesystem" => "/basesystem"
      mock.permissions "org.opensuse.yast.modules.basesystem", {}
      mock.get  "/basesystem.xml", header, response_bs, 200
    end
    session = {}
    bs = Basesystem.find session
    assert bs.completed?
  end

  def test_following_steps
    session = {:wizard_current => "systemtime", :wizard_steps => "systemtime,language:show" }
    bs = Basesystem.new.load_from_session session
    steps = bs.following_steps
    assert_equal 1,steps.size
    assert_equal "language", steps[0][:controller]
    assert_equal "show", steps[0][:action]
  end

end
