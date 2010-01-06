require File.join(File.dirname(__FILE__),'..','test_helper')
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'mocha'
require 'yast_mock'

class NetworkControllerTest < ActionController::TestCase
  # return contents of a fixture file +file+
  def fixture(file)
    IO.read(File.join(File.dirname(__FILE__), "..", "fixtures", file))
  end

  def setup
    # bypass authentication
    NetworkController.any_instance.stubs(:login_required)

    # stub what the REST is supposed to return
    response_ifcs = fixture "ifcs.xml"
    response_eth1 = fixture "ifc.xml"
    response_hn = fixture "hostname.xml"
    response_dns = fixture "dns.xml"
    response_rt = fixture "routes_default.xml"

    ActiveResource::HttpMock.set_authentification # ? vs login_required
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentification_header
      # this is inadequate, :singular is per resource,
      # and does NOT depend on :policy
      # see yast-rest-service/plugins/network/config/resources/*
      mock.resources({
        :"org.opensuse.yast.modules.yapi.network.dns" => "/network/dns",
        :"org.opensuse.yast.modules.yapi.network.hostname" => "/network/hostname",    
        :"org.opensuse.yast.modules.yapi.network.interfaces" => "/network/interfaces",
        :"org.opensuse.yast.modules.yapi.network.routes" => "/network/routes",
        }, { :policy => "org.opensuse.yast.modules.yapi.network" })
      mock.permissions "org.opensuse.yast.modules.yapi.network", { :read => true, :write => true }
      mock.get  "/network/interfaces.xml", header, response_ifcs, 200
#      mock.post   "/systemtime.xml", header, response_time, 200
      mock.get  "/network/interfaces/eth1.xml", header, response_eth1, 200
      mock.get  "/network/hostname.xml", header, response_hn, 200
      mock.get  "/network/dns.xml", header, response_dns, 200
      mock.get  "/network/routes/default.xml", header, response_rt, 200
    end
  end

  def test_should_show_it
    get :index
    assert_response :success
    assert_valid_markup
    # test just the last assignment, for brevity
    assert_not_nil assigns(:default_route)
    assert_not_nil assigns(:name)
  end

  def skip_test_with_dhcp
    @if_proxy.result["eth1"] = OpenStruct.new("bootproto" => "dhcp")
    get :index
    assert_response :success
    assert_valid_markup
    # test just the last assignment, for brevity
    assert_not_nil assigns(:default_route)
    assert_not_nil assigns(:name)
  end

  def skip_test_dhcp_without_change
    @if_proxy.result["eth1"] = OpenStruct.new("bootproto" => "dhcp")
    @if_proxy.expects(:save).never #don't call save if dhcp is not saved
    post :update, { :interface => "eth1", :conf_mode => "dhcp" }
    assert_response :redirect
    assert_redirected_to :action => "index"
  end

end
