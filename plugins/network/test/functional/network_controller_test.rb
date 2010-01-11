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
    response_eth2 = fixture "ifc-dhcp.xml"
    response_hn = fixture "hostname.xml"
    response_dns = fixture "dns.xml"
    response_rt = fixture "routes_default.xml"

    ActiveResource::HttpMock.set_authentication # ? vs login_required
    ActiveResource::HttpMock.respond_to do |mock|
      header = ActiveResource::HttpMock.authentication_header
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
      mock.get  "/network/interfaces/eth1.xml", header, response_eth1, 200
      mock.get  "/network/interfaces/eth2.xml", header, response_eth2, 200
      mock.get  "/network/hostname.xml", header, response_hn, 200
      mock.get  "/network/dns.xml", header, response_dns, 200
      mock.get  "/network/routes/default.xml", header, response_rt, 200
      # no mock.post/put, meaning we expect no saves
    end
  end

  def teardown
    ActiveResource::HttpMock.reset!
  end

  def test_should_show_it
    get :index
    assert_response :success
    assert_valid_markup
    # test just the last assignment, for brevity
    assert_not_nil assigns(:default_route)
    assert_not_nil assigns(:name)
  end

  def test_with_dhcp
    get :index, :interface => "eth2"
    assert_response :success
    assert_valid_markup
    # test just the last assignment, for brevity
    assert_not_nil assigns(:default_route)
    assert_not_nil assigns(:name)
  end

  def test_dhcp_without_change
    put :update, { :interface => "eth2", :conf_mode => "dhcp", :default_route => "192.168.1.1", :nameservers => "192.168.1.2 192.168.1.42", :searchdomains => "labs.example.com example.com", :name => "arthur", :domain => "britons" }
    assert_response :redirect
    assert_redirected_to :controller => "controlpanel", :action => "index"
  end

  # TODO also test the case in sample appliance (dhcp-only)
end
