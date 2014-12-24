require 'test_helper'

class PhoneTest < ActiveSupport::TestCase

  test "available inventory is listed" do
		@arrival_date = Date.today
		@departure_date = Date.today + Rails.configuration.delivery_transit_time_return

  	@phones = Phone.available_inventory(@arrival_date, @departure_date)
  	assert_equal @phones.length, Phone.all.length
  end

  test "if no inventory available none is listed" do
    @arrival_date = Date.today
    @departure_date = Date.today + Rails.configuration.delivery_transit_time_return
    Phone.destroy_all
    @phones = Phone.available_inventory(@arrival_date, @departure_date)
    assert_equal 0, Phone.all.length
  end

  test "past orders is empty" do
    @phone = create_phone(phones(:generic))
    @orders = @phone.past_orders
    assert_equal @orders.length, 0
  end

  test "past orders are found" do
    @phone = create_phone(phones(:generic))
    @order = create_order(orders(:past1))
    @phone.orders << @order
    @orders = @phone.past_orders
    assert_equal @orders.length, 1
  end

  test "current order does not count as a past order" do
    @phone = create_phone(phones(:generic))
    @order = create_order(orders(:current_order))
    @phone.orders << @order
    @orders = @phone.past_orders
    assert_equal @orders.length, 0
  end

  test "last order is correctly identified" do
    @phone = create_phone(phones(:generic))
    @order1 = create_order(orders(:past1)) # more recent entry
    @phone.orders << @order1
    @order2 = create_order(orders(:past2)) # older entry
    @phone.orders << @order2
    
    @last_order = @phone.last_order
    assert_equal @last_order.invoice_id, @order1.invoice_id
  end

  test "upcoming orders are found" do
  	@phone = create_phone(phones(:generic))
  	@order = create_order(orders(:upcoming_order))
  	@phone.orders << @order
  	@orders = @phone.upcoming_orders
  	assert_equal @orders.length, 1
	end

	test "upcoming orders are empty" do
  	@phone = create_phone(phones(:generic))
  	@order = create_order(orders(:current_order))
  	@phone.orders << @order
  	@orders = @phone.upcoming_orders
  	assert_equal @orders.length, 0
  end

  test "current order is true" do
  	@phone = create_phone(phones(:generic))
  	@order = create_order(orders(:current_order))
  	@phone.orders << @order

  	@order = @phone.current_order
  	assert_not_nil @order
	end

	test "current order is false 1" do
  	@phone = create_phone(phones(:generic))
  	@order = create_order(orders(:not_current_order_1))
  	@phone.orders << @order

  	@order = @phone.current_order
  	assert_nil @order
	end

	test "current order is false 2" do
  	@phone = create_phone(phones(:generic))
  	@order = create_order(orders(:not_current_order_2))
  	@phone.orders << @order

  	@order = @phone.current_order
  	assert_nil @order
	end

	test "check in works" do
		@phone = create_phone(phones(:generic))
  	@phone = Phone.check_in([@phone.inventory_id])
  	assert_not_nil @phone
	end

  test "when all phones received, order is marked complete" do
    @order = create_order(orders(:upcoming_order))
    @order.brute_force_assign_phones
    @phone = Phone.check_in([@order.phones[0]])
    
    @state_complete = EventState.order_completed
    @event = Event.where(
      event_state_id: @state_complete.id,
      order_id: @order.id)
    assert_not_nil @event
  end

  test "deactivating phone correctly reassigns upcoming orders" do
    @phone1 = create_phone(phones(:one))
    @phone2 = create_phone(phones(:two))
    # clear all other phones
    @other_phones = Phone.where.not(id:[@phone1.id, @phone2.id])
    @other_phones.destroy_all

    @order = create_order(orders(:upcoming_order)) # takes 1 phone
    @order.brute_force_assign_phones

    assert_equal 1, @order.phones.length
    assert_equal @phone1.inventory_id, @order.phones[0].inventory_id
    #puts "DEACTIVATED #{@order.phones[0].id}"
    @order.phones[0].deactivate
    # get latest data from db
    @order = Order.find(@order.id)
    # should have assigned a new phone to the slot
    assert_equal 1, @order.phones.length
    assert_not_equal @phone1.inventory_id, @order.phones[0].inventory_id
  end

  test "deactivating phone correctly" do # handles case where upcoming orders can't be reassigned" do
    @phone1 = create_phone(phones(:one))
    @order = create_order(orders(:upcoming_order)) # takes 1 phone
    @order.brute_force_assign_phones

    assert_equal 1, @order.phones.length
    assert_equal @phone1.inventory_id, @order.phones[0].inventory_id

    Phone.update_all(active: false)
    @exception = assert_raises(RuntimeError) { @order.phones[0].deactivate }
    assert_equal "No phones available", @exception.message
  end

end
