require File.dirname(__FILE__) + '/../test_helper'
require 'active_resource/http_mock'

class YastModelTest < ActiveSupport::TestCase

PERMISSION_RESPONSE= <<EOF
<permissions type="array">
  <permission>
    <granted type="boolean">true</granted>
    <id>org.opensuse.yast.modules.yapi.ntp.synchronize</id>
  <:w
  /permission>
</permissions>
EOF

RESOURCE_RESPONSE = <<EOF
<resources type="array">
  <resource>
    <interface>org.opensuse.yast.modules.test</interface>
    <policy/>
    <singular type="boolean">true</singular>
    <href>/test</href>
  </resource>
</resources>
EOF

TEST_RESPONSE = <<EOF
<test>
  <arg1>test</arg1>
</test>
EOF

def setup
  ActiveResource::HttpMock.respond_to do |mock|
    mock.get   "/resources.xml",   {}, RESOURCE_RESPONSE, 200
    mock.get   "/permissions.xml", {}, PERMISSION_RESPONSE,200
    mock.get   "/test.xml", {}, TEST_RESPONSE, 200
  end
  YaST::ServiceResource::Session.site = "http://localhost"
  YaST::ServiceResource::Session.login = "test"
  YaST::ServiceResource::Session.auth_token = "1234"
end

class Test < YastModel::Base
  model_interface :'org.opensuse.yast.modules.test'
end

def test_model
  assert Test.site.to_s.include?('localhost'), "site doesn't include localhost : #{Test.site}"
end

def test_find
  test = Test.find :one
  assert "test",test.arg1
end

end
