require 'test_helper'

class PhonesControllerTest < ActionController::TestCase
  setup do
    @phone = phones(:generic)
  end

  test "should get index" do
    get :index, :format => :json
    assert_response :success
    assert_not_nil assigns(:phones)
  end

  test "should get new" do
    get :new, :format => :json
    assert_response :success
  end

  test "should create phone" do
    assert_difference('Phone.count') do
      post :create, :format => :json, phone: @phone.attributes
    end

    body = JSON.parse(response.body)
    assert body["MEID"] == @phone.MEID
    assert_response :created
  end

  test "should show phone" do
    get :show, :format => :json, id: @phone.inventory_id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :format => :json, id: @phone.inventory_id
    assert_response :success
  end

  test "should update phone" do
    patch :update, :format => :json, id: @phone.inventory_id, phone: @phone.attributes
    assert_response :success
  end

  test "should destroy phone" do
    assert_difference('Phone.count', -1) do
      delete :destroy, :format => :json, id: @phone.inventory_id
    end

    assert_response :success
  end

  test "should show available inventory" do
    get :available_inventory, :format => :json
    assert_response :success
    assert_not_nil assigns(:phones)
  end

  test "should show upcoming orders" do
    get :upcoming_orders, :format => :json, id: @phone
    assert_response :success
    assert assigns(:orders), []
    # TODO could expand with more tests here
  end

  test "should check in a phone" do
    post :check_in, :format => :json, inventory_ids: [@phone.inventory_id]
    assert_response :success
    assert_equal assigns(:phones)[0].inventory_id, @phone.inventory_id
    # TODO could expand with more tests here
  end

  test "should show current order if one exists" do
    get :current_order, :format => :json, id: @phone
    assert_response :success
    assert assigns(:orders), []
    # TODO could expand with more tests here
  end

end
