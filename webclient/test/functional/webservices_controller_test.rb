require 'test_helper'

class WebservicesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:webservices)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_webservice
    assert_difference('Webservice.count') do
      post :create, :webservice => { }
    end

    # after creating we redirect to the full list
    assert_redirected_to webservices_path
  end

  def test_should_show_webservice
    get :show, :id => webservices(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => webservices(:one).id
    assert_response :success
  end

  def test_should_update_webservice
    put :update, :id => webservices(:one).id, :webservice => { }
    # after creating we redirect to the full list
    assert_redirected_to webservices_path
  end

  def test_should_destroy_webservice
    assert_difference('Webservice.count', -1) do
      delete :destroy, :id => webservices(:one).id
    end

    assert_redirected_to webservices_path
  end
end
