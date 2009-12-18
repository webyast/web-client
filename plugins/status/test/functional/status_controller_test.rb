require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
require 'test/unit'
require File.expand_path( File.join("test","validation_assert"), RailsParent.parent )
require 'mocha'

#extra ugly hack for dynamic created type
module YaST
  module ServiceResource
    module Proxies
      module Status
        module Metric
          module Label
          end
        end
      end
    end
  end
end


class StatusControllerTest < ActionController::TestCase

class Log
  attr_accessor :description,:id,:path
  def initialize(d,i,p)
    @description =d
    @id = i
    @path = p
  end
end

DEFINED_LOGS = [
  Log.new("test","test","/log/test"),
  Log.new("test2","test2","/log/test2")
]

  class StatusProxy
    attr_accessor :result, :permissions, :timeout
    def initialize
      @permissions = { :read => true, :write => :true}
    end
    def find(arg=nil,arg2=nil)
      return StatusMock.new
    end
  end

  class LogsProxy
    attr_accessor :result, :permissions, :timeout
    def initialize
      @permissions = { :read => true, :write => :true}
    end
    def find(arg)
      return @result
    end
  end

class MetricMock 
  attr_accessor :name, :metricgroup, :interval, :starttime
  def initialize (n,m,i,s)
    @name = n
    @metricgroup = m
    @interval = i
    @starttime = s
  end

  def attributes
    { "label" => ""}
  end
end

ATTR_DATA = {
  "metric" => [
      MetricMock.new("test","tg",5,Time.now())
    ],
  "label" => "" #hach to avoid creating horrible mockup
}

  class StatusMock
    def attributes
      ATTR_DATA
    end
  end

  def setup
    StatusController.any_instance.stubs(:login_required)
    @controller = StatusController.new
    @request = ActionController::TestRequest.new
    # http://railsforum.com/viewtopic.php?id=1719
    @request.session[:account_id] = 1 # defined in fixtures
    @logs_proxy = LogsProxy.new
    @logs_proxy.result = DEFINED_LOGS
  end

  def test_index
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.system.logs').returns(@logs_proxy)
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.system.status').returns(StatusProxy.new)
    get :index

    assert_response :success
    assert_valid_markup
    assert assigns(:logs)
  end

OUT_SYNC_ERROR = <<EOF
<error>
  <type>COLLECTD_SYNC_ERROR</type>
  <description>blba bla</description>
</error>
EOF

class ResponseMock
  def body
    return OUT_SYNC_ERROR
  end

  def code
    return "503"
  end
end

#status module must survive collectd out of sync
  def test_collectd_out_of_sync
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.system.logs').returns(@logs_proxy)
    sproxy = StatusProxy.new
    YaST::ServiceResource.stubs(:proxy_for).with('org.opensuse.yast.system.status').returns(sproxy)
    sproxy.stubs(:find).raises(ActiveResource::ServerError.new(ResponseMock.new,""))
    get :index

    assert_response :success
    assert_valid_markup
    assert assigns(:logs)
  end

end
