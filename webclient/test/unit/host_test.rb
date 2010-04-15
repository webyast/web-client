require File.dirname(__FILE__) + '/../test_helper'

class HostTest < ActiveSupport::TestCase

  test "creation of a new host" do
    host = Host.new
    assert host
    host.name = "test"
    host.url = "http://localhost:3000"
    assert host.save
  end
  
  test "deletion of a host" do
    host = Host.new
    assert host
    host.name = "test"
    host.url = "http://localhost:3000"
    assert host.save
    host.destroy
    assert_raise ActiveRecord::RecordNotFound do
      Host.find(host.id)
    end
  end
  
  test "uniqueness in name" do
    host1 = Host.new
    host1.name = "test"
    host1.url = "http://localhost:3000"
    host1.save
    host2 = Host.new
    host2.name = "test"
    host2.url = "http://localhost:3000"
    assert_raise ActiveRecord::RecordInvalid do
      host2.save!
    end
  end
  
  test "validity of url" do
    host = Host.new
    host.name = "test"
    host.url = "12345"
    assert_raise ActiveRecord::RecordInvalid do
      host.save!
    end
  end
  
  test "name is non-empty" do
    host = Host.new
    host.url = "http://localhost:3000"
    assert_raise ActiveRecord::RecordInvalid do
      host.save!
    end
  end

  test "find by id or name" do
    host = Host.new
    host.name = "test"
    host.url = "http://localhost:3000"
    assert host.save
    h1 = Host.find_by_id_or_name(host.id)
    h2 = Host.find_by_id_or_name(host.name)
    assert h1
    assert h2
    assert_equal h1, h2
  end
end
