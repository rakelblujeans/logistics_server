require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  setup do
    @order = orders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:orders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create order" do
    assert_difference('Order.count') do
      post :create, order: { arrival_date: @order.arrival_date, customer_id: @order.customer_id, delivery_type: @order.delivery_type, departure_date: @order.departure_date, fedex_out_code: @order.fedex_out_code, fedex_return_code: @order.fedex_return_code, full_address: @order.full_address, language: @order.language, num_phones: @order.num_phones, order_state: @order.order_state, phone_id: @order.phone_id, shipping_apt_suite: @order.shipping_apt_suite, shipping_city: @order.shipping_city, shipping_country: @order.shipping_country, shipping_name: @order.shipping_name, shipping_notes: @order.shipping_notes, shipping_state: @order.shipping_state, shipping_zip: @order.shipping_zip }
    end

    assert_redirected_to order_path(assigns(:order))
  end

  test "should show order" do
    get :show, id: @order
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @order
    assert_response :success
  end

  test "should update order" do
    patch :update, id: @order, order: { arrival_date: @order.arrival_date, customer_id: @order.customer_id, delivery_type: @order.delivery_type, departure_date: @order.departure_date, fedex_out_code: @order.fedex_out_code, fedex_return_code: @order.fedex_return_code, full_address: @order.full_address, language: @order.language, num_phones: @order.num_phones, order_state: @order.order_state, phone_id: @order.phone_id, shipping_apt_suite: @order.shipping_apt_suite, shipping_city: @order.shipping_city, shipping_country: @order.shipping_country, shipping_name: @order.shipping_name, shipping_notes: @order.shipping_notes, shipping_state: @order.shipping_state, shipping_zip: @order.shipping_zip }
    assert_redirected_to order_path(assigns(:order))
  end

  test "should destroy order" do
    assert_difference('Order.count', -1) do
      delete :destroy, id: @order
    end

    assert_redirected_to orders_path
  end
end
