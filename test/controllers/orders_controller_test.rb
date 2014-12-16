require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  setup do
    @order = orders(:generic)
    @phone1 = phones(:generic)
    @phone2 = phones(:one)
    @phone3 = phones(:two)
    @phone4 = phones(:three)
  end

  test "should get index" do
    get :index, :format => :json
    assert_response :success
    assert_not_nil assigns(:orders)
  end

  test "should get new" do
    get :new, :format => :json
    assert_response :success
  end

  test "should create order" do
    assert_difference('Order.count') do
      post :create, :format => :json, order: @order.attributes
    end

    body = JSON.parse(response.body)
    assert body["invoice_id"] == @order.invoice_id
    assert_response :created
  end

  test "should show order" do
    get :show, :format => :json, id: @order
    assert_response :success
    assert_not_nil assigns(:is_verified)
  end

  test "should get edit" do
    get :edit, :format => :json, id: @order
    assert_response :success
  end

  test "should update order" do
    patch :update, :format => :json, id: @order, order: @order.attributes
    #assert_redirected_to order_path(assigns(:order))
    assert_response :success
  end

  test "should destroy order" do
    assert_difference('Order.count', -1) do
      delete :destroy, :format => :json, id: @order
    end

    assert_response :success
  end

  test "should get unverified orders" do
    get :unverified, :format => :json
    assert_response :ok
    assert_not_nil assigns(:orders)
  end

  test "should get verified orders" do
    get :unverified, :format => :json
    assert_response :ok
    assert_not_nil assigns(:orders)
  end

  test "should verify an order" do
    assert_difference('Event.count') do
      post :mark_verified, :format => :json, id: @order
    end
    assert_response :ok
    assert_not_nil assigns(:order)
  end

  test "should assign a device" do
    assert_difference('@order.phones.count') do
      post :assign_device, :format => :json, id: @order, phone_id: @phone1.id
    end
    assert_not_nil assigns(:order)
  end

  test "should unassign a device" do
    post :assign_device, :format => :json, id: @order, phone_id: @phone1.id
    assert_difference('@order.phones.count', -1) do
      post :unassign_device, :format => :json, id: @order, phone_id: @phone1.id
    end
    assert_not_nil assigns(:order)
  end

end
