require 'test_helper'

class OrderStatesControllerTest < ActionController::TestCase
  setup do
    @order_state = order_states(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:order_states)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create order_state" do
    assert_difference('OrderState.count') do
      post :create, order_state: { name: @order_state.name }
    end

    assert_redirected_to order_state_path(assigns(:order_state))
  end

  test "should show order_state" do
    get :show, id: @order_state
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @order_state
    assert_response :success
  end

  test "should update order_state" do
    patch :update, id: @order_state, order_state: { name: @order_state.name }
    assert_redirected_to order_state_path(assigns(:order_state))
  end

  test "should destroy order_state" do
    assert_difference('OrderState.count', -1) do
      delete :destroy, id: @order_state
    end

    assert_redirected_to order_states_path
  end
end
