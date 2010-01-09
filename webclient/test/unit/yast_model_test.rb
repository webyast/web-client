require File.dirname(__FILE__) + '/../test_helper'
require 'yast_mock'

class YastModelTest < ActiveSupport::TestCase

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
  ActiveResource::HttpMock.set_authentication
  ActiveResource::HttpMock.respond_to do |mock|
    header = ActiveResource::HttpMock.authentication_header
    mock.resources :'org.opensuse.yast.modules.test' => "/test", :'org.opensuse.yast.modules.test2' => "/test2"
    mock.permissions "org.opensuse.yast.modules.test", { :synchronize => true }
    mock.get   "/test.xml", header, TEST_RESPONSE, 200
    mock.post   "/test.xml", header, TEST_RESPONSE, 200
    mock.get   "/test2.xml", header, TEST2_RESPONSE, 200
    mock.post   "/test2.xml", header, TEST2_RESPONSE, 200
  end
  TestModel.set_site #reset site cache
  Test2Model.set_site
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
  test = TestModel.find :one
  assert_equal TEST_STRING,test.arg1
  assert_equal TEST2_STRING,test2.arg1
  assert_equal "test",TestModel.collection_name
  assert_equal "test2",Test2Model.collection_name
end

def test_permissions
  perm = TestModel.permissions
  assert perm[:synchronize], "permission is not granted #{perm.inspect}"
end

def test_specified_policy
  ActiveResource::HttpMock.respond_to do |mock|
    header = ActiveResource::HttpMock.authentication_header
    mock.resources({:'org.opensuse.yast.modules.test' => "/test", :'org.opensuse.yast.modules.test2' => "/test2"}, { :policy => "org.perm" })
    mock.permissions "org.perm", { :synchronize => true }
    mock.get   "/test.xml", header, TEST_RESPONSE, 200
    mock.post   "/test.xml", header, TEST_RESPONSE, 200
  end
  TestModel.set_site #reset site cache, to reread resources
  perm = TestModel.permissions
  assert_equal "org.perm", TestModel.permission_prefix
  assert perm[:synchronize], "permission is not granted #{perm.inspect}"
end

end
