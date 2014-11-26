require 'test_helper'

class EventStatesControllerTest < ActionController::TestCase
  setup do
    @event_state = event_states(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:event_states)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event_state" do
    assert_difference('EventState.count') do
      post :create, event_state: {  }
    end

    assert_redirected_to event_state_path(assigns(:event_state))
  end

  test "should show event_state" do
    get :show, id: @event_state
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event_state
    assert_response :success
  end

  test "should update event_state" do
    patch :update, id: @event_state, event_state: {  }
    assert_redirected_to event_state_path(assigns(:event_state))
  end

  test "should destroy event_state" do
    assert_difference('EventState.count', -1) do
      delete :destroy, id: @event_state
    end

    assert_redirected_to event_states_path
  end
end
