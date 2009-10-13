require 'test_helper'
require 'ostruct'

class OpenStruct
  undef_method :id # so that it looks for our id
end

class NetworkControllerTest < ActionController::TestCase

  class Proxy
    attr_accessor :result, :timeout
    def permissions
      return { :read => true, :execute => true }
    end
  end

  class Proxy1 < Proxy
    def find
      return result
    end
  end

  class ProxyN < Proxy
    def find(arg)
      return result
    end
  end

  class ProxyH < Proxy
    def find(arg)
      return result[arg]
    end
  end

  def setup
    # bypass authentication
    NetworkController.any_instance.stubs(:login_required)

    # stub what the REST is supposed to return
    @if_proxy = ProxyH.new
    @if_proxy.result = {
      :all => [ OpenStruct.new("id" => "eth1") ],
      "eth1" => OpenStruct.new("id" => "eth1", "ipaddr" => '10.20.30.42/24')
    }

    @hn_proxy = Proxy1.new
    @hn_proxy.result = OpenStruct.new("name" => "Arthur, king of the Britons")

    @dns_proxy = Proxy1.new
    @dns_proxy.result = OpenStruct.new("nameservers" => ["n1", "n2"], "searches" => ["s1", "s2"])

    @rt_proxy = ProxyN.new
    @rt_proxy.result = OpenStruct.new("via" => 'mygw')

    def x # a shorthand. return another stub
       YaST::ServiceResource.stubs(:proxy_for)
    end
    x.with('org.opensuse.yast.modules.yapi.network.interfaces').returns(@if_proxy)
    x.with('org.opensuse.yast.modules.yapi.network.hostname').returns(@hn_proxy)
    x.with('org.opensuse.yast.modules.yapi.network.dns').returns(@dns_proxy)
    x.with('org.opensuse.yast.modules.yapi.network.routes').returns(@rt_proxy)
  end

  def test_should_show_it
    get :index
    assert_response :success
    # test just the last assignment, for brevity
    assert_not_nil assigns(:default_route)
    assert_not_nil assigns(:name)
  end

  def test_with_dhcp
    @if_proxy.result["eth1"] = OpenStruct.new("bootproto" => "dhcp")
    get :index
    assert_response :success
    # test just the last assignment, for brevity
    assert_not_nil assigns(:default_route)
    assert_not_nil assigns(:name)
  end

end
