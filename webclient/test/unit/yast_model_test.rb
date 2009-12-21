require File.dirname(__FILE__) + '/../test_helper'
require 'active_resource/http_mock'

class YastModelTest < ActiveSupport::TestCase

PERMISSION_RESPONSE= <<EOF
<permissions type="array">
  <permission>
    <granted type="boolean">true</granted>
    <id>org.opensuse.yast.modules.test.synchronize</id>
  </permission>
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
  <resource>
    <interface>org.opensuse.yast.modules.test2</interface>
    <policy/>
    <singular type="boolean">true</singular>
    <href>/test2</href>
  </resource>
</resources>
EOF

TEST_RESPONSE = <<EOF
<test>
  <arg1>test</arg1>
</test>
EOF

TEST2_RESPONSE = <<EOF
<test2>
  <arg1>test2</arg1>
</test2>
EOF

TEST_STRING = "test"
TEST2_STRING = "test2"

def setup
  ActiveResource::HttpMock.respond_to do |mock|
    mock.get   "/resources.xml",   {}, RESOURCE_RESPONSE, 200
    mock.get   "/permissions.xml?filter=org.opensuse.yast.modules.test&user_id=test", {"Authorization"=>"Basic OjEyMzQ="}, PERMISSION_RESPONSE,200
    mock.get   "/test.xml", {"Authorization"=>"Basic OjEyMzQ="}, TEST_RESPONSE, 200
    mock.post   "/test.xml", {"Authorization"=>"Basic OjEyMzQ="}, TEST_RESPONSE, 200
    mock.get   "/test2.xml", {"Authorization"=>"Basic OjEyMzQ="}, TEST2_RESPONSE, 200
    mock.post   "/test2.xml", {"Authorization"=>"Basic OjEyMzQ="}, TEST2_RESPONSE, 200
  end
  YaST::ServiceResource::Session.site = "http://localhost"
  YaST::ServiceResource::Session.login = "test"
  YaST::ServiceResource::Session.auth_token = "1234"
end

class TestModel < ActiveResource::Base
  extend YastModel::Base
  model_interface :'org.opensuse.yast.modules.test'
end
class Test2Model < ActiveResource::Base
  extend YastModel::Base
  model_interface :'org.opensuse.yast.modules.test2'
end

def test_model
  assert TestModel.site.to_s.include?('localhost'), "site doesn't include localhost : #{TestModel.site}"
  assert_equal "test",TestModel.collection_name
  assert_equal "/",TestModel.prefix
end

def test_find_and_save
  begin
    test = TestModel.find :one
    assert_equal TEST_STRING,test.arg1
    assert test.save
  ensure
    Rails.logger.debug ActiveResource::HttpMock.requests.inspect
  end
end

def test_mix_of_two_models
  test = TestModel.find :one
  assert_equal TEST_STRING,test.arg1
  test2 = Test2Model.find :one
  assert_equal TEST2_STRING,test2.arg1
  assert_equal TEST_STRING,test.arg1
  assert_equal "test",TestModel.collection_name
  assert_equal "test2",Test2Model.collection_name
end

def test_permissions
  perm = TestModel.permissions
  assert perm[:synchronize], "permission is not granted #{perm.inspect}"
end

end
