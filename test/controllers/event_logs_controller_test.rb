require 'test_helper'

class EventLogsControllerTest < ActionController::TestCase
  setup do
    @event_log = event_logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:event_logs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event_log" do
    assert_difference('EventLog.count') do
      post :create, event_log: {  }
    end

    assert_redirected_to event_log_path(assigns(:event_log))
  end

  test "should show event_log" do
    get :show, id: @event_log
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @event_log
    assert_response :success
  end

  test "should update event_log" do
    patch :update, id: @event_log, event_log: {  }
    assert_redirected_to event_log_path(assigns(:event_log))
  end

  test "should destroy event_log" do
    assert_difference('EventLog.count', -1) do
      delete :destroy, id: @event_log
    end

    assert_redirected_to event_logs_path
  end
end
