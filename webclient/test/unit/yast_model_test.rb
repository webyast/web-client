#--
# Webyast Webservice framework
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

require File.dirname(__FILE__) + '/../test_helper'

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

CTEST_RESPONSE = <<EOF
<ctest>
  <arg1 type="array">
    <arg1>
      <value type="boolean">true</value>
    </arg1>
    <arg1>
      <value type="boolean">false</value>
    </arg1>
    <arg1>
      <value type="array">
        <value>test</value>
      </value>
    </arg1>
  </arg1>
  <actions>
    <action1> <active type="boolean"> false </active></action1>
  </actions>
</ctest>
EOF

TEST_STRING = "test"
TEST2_STRING = "test2"

def setup
  ActiveResource::HttpMock.set_authentication
  ActiveResource::HttpMock.respond_to do |mock|
    header = ActiveResource::HttpMock.authentication_header
    mock.resources :'org.opensuse.yast.modules.test' => "/test", :'org.opensuse.yast.modules.test2' => "/test2", :'org.opensuse.yast.modules.complex_test' => "/ctest"
    mock.permissions "org.opensuse.yast.modules.test", { :synchronize => true }
    mock.get   "/test.xml", header, TEST_RESPONSE, 200
    mock.post   "/test.xml", header, TEST_RESPONSE, 200
    mock.get   "/test2.xml", header, TEST2_RESPONSE, 200
    mock.post   "/test2.xml", header, TEST2_RESPONSE, 200
    mock.get   "/ctest.xml", header, CTEST_RESPONSE, 200
    mock.post   "/ctest.xml", header, CTEST_RESPONSE, 200
  end
  ResourceCache.instance.send(:permissions=,[]) #reset cache
  ResourceCache.instance.send(:resources=,[]) #reset cache
  TestModel.set_site #reset site cache
  Test2Model.set_site
end

def test_available_interfaces
  assert YastModel::Resource.interfaces_available?(:'org.opensuse.yast.modules.test', :'org.opensuse.yast.modules.test2')
  assert !YastModel::Resource.interfaces_available?(:'org.opensuse.yast.modules')
end

class TestModel < ActiveResource::Base
  extend YastModel::Base
  model_interface :'org.opensuse.yast.modules.test'
end
class Test2Model < ActiveResource::Base
  extend YastModel::Base
  model_interface :'org.opensuse.yast.modules.test2'
end
class ComplexTestModel < ActiveResource::Base
  extend YastModel::Base
  model_interface :'org.opensuse.yast.modules.complex_test'
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
  ResourceCache.instance.send(:permissions=,[]) #reset cache
  ResourceCache.instance.send(:resources=,[]) #reset cache
  TestModel.set_site #reset site cache, to reread resources
  perm = TestModel.permissions
  assert_equal "org.perm", TestModel.permission_prefix
  assert perm[:synchronize], "permission is not granted #{perm.inspect}"
end

TEST_ARRAY = [ "a","b",["bc","g"]]
TEST_HASH = { :e => :symbol }
RESULT_HASH = { "e" => :symbol } #stupid hash key doesn't survive as symbol and it is always string
def test_save_complex_xml
  begin
    test = TestModel.find :one
    assert_equal TEST_STRING,test.arg1

    test.arg1 = {
      :array => TEST_ARRAY,
      :hash => TEST_HASH
    }
    assert test.save
    rq = ActiveResource::HttpMock.requests.find {
        |r| r.method == :post && r.path == "/test.xml"}
    assert rq #commit request send
    assert rq.body
    result = Hash.from_xml(rq.body)["test"]["arg1"]
    assert_equal TEST_ARRAY, result["array"]
    assert_equal RESULT_HASH, result["hash"]
  ensure
    Rails.logger.debug ActiveResource::HttpMock.requests.inspect
  end
end

def test_save_deep_array_xml
  begin
    test = ComplexTestModel.find :one
    assert test.arg1[0].value
    assert !test.arg1[1].value
    assert !test.actions.action1.active
    assert_equal "test", test.arg1[2].value[0]

    test.arg1[0].value = false
    test.actions.action1.active = true
    test.arg1[2].value = ["lest","zvest"]
    assert test.save
    rq = ActiveResource::HttpMock.requests.find {
        |r| r.method == :post && r.path == "/ctest.xml"}
    assert rq #commit request send
    assert rq.body
    result = Hash.from_xml(rq.body)["ctest"]
    assert_equal true, result["actions"]["action1"]["active"]
    assert_equal false, result["arg1"][0]["value"]
    assert_equal "lest", result["arg1"][2]["value"][0]
    assert_equal "zvest", result["arg1"][2]["value"][1]
  ensure
    Rails.logger.debug ActiveResource::HttpMock.requests.inspect
  end
end

  def test_permissions_serialization
    p1 = YastModel::Permission.new :granted => false, :id => "org.test"
    p2 = YastModel::Permission.new :granted => true, :id => "org.test2"
    p3 = YastModel::Permission.load_from_string p1.serialize_to_string
    assert_equal p1.id, p3.id
    assert_equal p1.granted, p3.granted
    p3 = YastModel::Permission.load_from_string p2.serialize_to_string
    assert_equal p2.id, p3.id
    assert_equal p2.granted, p3.granted
  end

  def test_resource_serialization
    r1 = YastModel::Resource.new :interface => "org.test", :policy => "",
            :singular => true, :href => "/test"
    r2 = YastModel::Resource.load_from_string r1.serialize_to_string
    assert_equal r1.interface, r2.interface
    assert_equal r1.policy, r2.policy
    assert_equal r1.singular, r2.singular
    assert_equal r1.href, r2.href
  end

end
