require 'test_helper'

class ShipmentsControllerTest < ActionController::TestCase
  setup do
    @shipment = shipments(:incoming_today)
    @order = orders(:incoming_today)
    @shipment.order_id = @order.id
  end

  test "should get index" do
    get :index, :format => :json
    assert_response :success
    assert_not_nil assigns(:shipments)
  end

  test "should get new" do
    get :new, :format => :json
    assert_response :success
  end

  test "should create shipment" do
    assert_difference('Shipment.count') do
      post :create, :format => :json, shipment: @shipment.attributes
    end

    body = JSON.parse(response.body)
    assert body["delivery_out_code"] == @shipment.delivery_out_code
    assert_response :created
  end

  test "should show shipment" do
    get :show, :format => :json, id: @shipment
    assert_response :success
  end

  test "should get edit" do
    get :edit, :format => :json, id: @shipment
    assert_response :success
  end

  test "should update shipment" do
    patch :update, :format => :json, id: @shipment, shipment: @shipment.attributes
    assert_response :success
  end

  test "should destroy shipment" do
    assert_difference('Shipment.count', -1) do
      delete :destroy, :format => :json, id: @shipment
    end

    assert_response :success
  end
end
