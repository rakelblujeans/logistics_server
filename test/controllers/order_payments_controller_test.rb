require 'test_helper'

class OrderPaymentsControllerTest < ActionController::TestCase
  setup do
    @order_payment = order_payments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:order_payments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create order_payment" do
    assert_difference('OrderPayment.count') do
      post :create, order_payment: { bt_trans_id: @order_payment.bt_trans_id, credit_card_id: @order_payment.credit_card_id, discount_code: @order_payment.discount_code, discount_string: @order_payment.discount_string, last_4_digits: @order_payment.last_4_digits, order_id: @order_payment.order_id, payment_amount: @order_payment.payment_amount, payment_date: @order_payment.payment_date, payment_status: @order_payment.payment_status, referral_code: @order_payment.referral_code, refunded: @order_payment.refunded, rental_charge: @order_payment.rental_charge, rental_discount: @order_payment.rental_discount, shipping_charge: @order_payment.shipping_charge, shipping_string: @order_payment.shipping_string, tax_charge: @order_payment.tax_charge }
    end

    assert_redirected_to order_payment_path(assigns(:order_payment))
  end

  test "should show order_payment" do
    get :show, id: @order_payment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @order_payment
    assert_response :success
  end

  test "should update order_payment" do
    patch :update, id: @order_payment, order_payment: { bt_trans_id: @order_payment.bt_trans_id, credit_card_id: @order_payment.credit_card_id, discount_code: @order_payment.discount_code, discount_string: @order_payment.discount_string, last_4_digits: @order_payment.last_4_digits, order_id: @order_payment.order_id, payment_amount: @order_payment.payment_amount, payment_date: @order_payment.payment_date, payment_status: @order_payment.payment_status, referral_code: @order_payment.referral_code, refunded: @order_payment.refunded, rental_charge: @order_payment.rental_charge, rental_discount: @order_payment.rental_discount, shipping_charge: @order_payment.shipping_charge, shipping_string: @order_payment.shipping_string, tax_charge: @order_payment.tax_charge }
    assert_redirected_to order_payment_path(assigns(:order_payment))
  end

  test "should destroy order_payment" do
    assert_difference('OrderPayment.count', -1) do
      delete :destroy, id: @order_payment
    end

    assert_redirected_to order_payments_path
  end
end
