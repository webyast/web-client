require File.dirname(__FILE__) + '/../test_helper'

class HostsControllerTest < ActionController::TestCase
  fixtures :hosts

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:hosts)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_host
    assert_difference('Host.count') do
      post :create, :host => { :name => "new host", :url => "http://www.rubyonrails.org", :description => "Rails" }
    end

    # after creating we redirect to the full list
    assert_redirected_to hosts_path
  end

  def test_should_fail_create_host
    post :create, :host => { } # empty :host hash

    assert_redirected_to new_host_path
  end

  # re-create the first host of the fixture
  def test_host_uniqueness
    host = Host.find(:first)
    assert host
    post :create, :host => { :name => host.name, :url => host.url, :description => host.description }

    assert_redirected_to new_host_path
  end

  def test_should_show_host
    get :show, :id => hosts(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => hosts(:one).id
    assert_response :success
  end

  def test_should_update_host
    put :update, :id => hosts(:one).id, :host => { }
    # after creating we redirect to the full list
    assert_redirected_to hosts_path
  end

  def test_should_destroy_host
    assert_difference('Host.count', -1) do
      delete :destroy, :id => hosts(:one).id
    end

    assert_redirected_to hosts_path
  end
end
