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
    get :index, :format => :json, 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(users(:admin).name, users(:admin).password)
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

  test "should show incoming orders" do
    get :incoming_on, :format => :json, id: @phone1, date: Date.today
    assert_response :success
    assert assigns(:data), []
    # TODO could expand with more tests here
  end

  test "should show outbound orders" do
    get :outbound_on, :format => :json, id: @phone1, date: Date.today
    assert_response :success
    assert assigns(:data), []
    # TODO could expand with more tests here
  end

  test "mark order complete" do
    post :mark_complete, :format => :json, invoice_id: @order.invoice_id
    #assert_response :success
    assert_not_nil assigns(:order)
  end

  test "overdue" do
    get :overdue, :format => :json
    assert_response :success
    assert assigns(:orders), []
  end

  test "overdue_shipping" do
    get :overdue_shipping, :format => :json
    assert_response :success
    assert assigns(:orders), []
  end

  test "missing_phones" do
    get :missing_phones, :format => :json
    assert_response :success
    assert assigns(:orders), []
  end

  test "toggle_activation" do
    assert_equal true, @order.active
    get :toggle_activation, :format => :json, id: @order.id
    assert_response :success
    assert assigns(:order), []
    assert_equal false, assigns(:order).active
  end

end
