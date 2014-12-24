require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  test "unverified order passes unverified check" do
  	@order = create_order(orders(:generic))
  	assert_equal 1, Order.unverified.length
  end

  test "unverified order fails verified check" do
  	@order = create_order(orders(:generic))
  	assert_equal 0, Order.verified.length
  end

  test "mark order verified" do
  	@order = create_order(orders(:generic))
  	@order.mark_verified
  	assert_equal 0, Order.unverified.length
  	assert_equal 1, Order.verified.length
  end

  test "is_verified marks verified orders as true" do
    @order = create_order(orders(:generic))
    @order.mark_verified
    assert_equal @order.is_verified, true
  end

  test "is_verified marks unverified orders as false" do
    @order = create_order(orders(:generic))
    assert_equal @order.is_verified, false
  end

  test "assign device" do
  	@phone = create_phone(phones(:generic))
  	@order = create_order(orders(:generic))
  	@order.assign_device(@phone.id)

  	assert @order.phones[0].id == @phone.id
  	assert @order.events[@order.events.length - 1].event_state_id == EventState.matched_inventory.id
	end

	test "unassign device" do
  	@phone = create_phone(phones(:generic))
  	@order = create_order(orders(:generic))
  	@order.assign_device(@phone.id)
  	@order.unassign_device(@phone.id)

		assert_equal 0, @order.phones.length
  	assert_not_equal @order.events[@order.events.length - 1].event_state_id, EventState.matched_inventory.id
	end

	test "brute force assign phone" do
		@phone1 = create_phone(phones(:generic))
		@phone2 = create_phone(phones(:generic))
		@phone3 = create_phone(phones(:generic))
  	@order = create_order(orders(:generic))
  	@order.brute_force_assign_phones

  	assert_equal @order.phones.length, @order.num_phones
  	@events = Event.where(event_state_id: EventState.matched_inventory.id)
  	assert_equal @events.length, @order.num_phones
	end

  test "brute force assign phones raises exception when no phones available" do
    @order = create_order(orders(:generic))
    Phone.destroy_all
    @exception = assert_raises(RuntimeError) { @order.brute_force_assign_phones }
    assert_equal "No phones available", @exception.message
  end

  test "overlapping orders get assigned different phones" do
    @phone1 = create_phone(phones(:generic))
    @phone2 = create_phone(phones(:one))
    @phone3 = create_phone(phones(:two))

    @order1 = create_order(orders(:incoming_today))
    @order1.brute_force_assign_phones
    @order2 = create_order(orders(:current_order))
    @order2.brute_force_assign_phones

    assert_equal @order1.phones.length, @order1.num_phones
    assert_equal @order2.phones.length, @order2.num_phones
    assert_not_equal @order1.phones, @order2.phones
  end

    test "order incoming today is true" do
    @phone = create_phone(phones(:generic))
    @order = create_order(orders(:incoming_today))
    @phone.orders << @order
    @order.mark_verified
    @ship = create_shipment(shipments(:incoming_today), @order, @phone)
    @order.shipments << @ship

    @orders = Order.incoming_on(Date.today)
    assert_equal 1, @orders.length
  end

  test "order incoming today if false" do
    @phone = create_phone(phones(:generic))
    @order = create_order(orders(:not_incoming_today))
    @phone.orders << @order
    @order.mark_verified

    @ship = create_shipment(shipments(:not_incoming_today), @order, @phone)
    @order.shipments << @ship

    @orders = Order.incoming_on(Date.today)
    assert_equal 0, @orders.length
  end

  test "outbound order today is true" do
    @phone = create_phone(phones(:generic))
    @order = create_order(orders(:outbound_today))
    @phone.orders << @order
    @order.mark_verified

    @orders = Order.outbound_on(Date.today)
    assert_equal 1, @orders.length
  end

  test "outbound order today is false" do
    @phone = create_phone(phones(:generic))
    @order = create_order(orders(:outbound_yesterday))
    @phone.orders << @order
    @order.mark_verified

    @orders = Order.outbound_on(Date.today)
    assert_equal 0, @orders.length
  end

  test "phones still out correctly recognized" do
    @order = create_order(orders(:incoming_today))

    @phone = create_phone(phones(:generic))
    @phone.orders << @order
    @order.mark_verified
    @ship = create_shipment(shipments(:generic), @order, @phone)
    @order.shipments << @ship
    
    assert_equal 1, @order.phones_still_out.length
    Phone.check_in(@phone.inventory_id)
    assert_equal 0, @order.phones_still_out.length
  end

  test "marking order done works" do
    @order = create_order(orders(:current_order)) # has 2 phones
    @phone1 = create_phone(phones(:one))
    @phone2 = create_phone(phones(:two))
    #@phone.orders << @order
    @order.phones << [@phone1, @phone2]
    @order.mark_verified
    @ship1 = create_shipment(shipments(:generic), @order, @phone1)
    @ship2 = create_shipment(shipments(:generic), @order, @phone2)
    @order.shipments << [@ship1, @ship2]
    
    
    Order.mark_complete(@order.invoice_id)
    assert_equal 0, @order.phones_still_out.length

    @state_completed = EventState.order_completed
    @found_event = Event.where(
      order_id: @order.id, 
      event_state_id: @state_completed.id)
    assert_equal @found_event.length, 1
  end

  test "orders out in the field are identified" do
    @orders_created = [
      create_order(orders(:current_order)),
      create_order(orders(:current_order2)),
      create_order(orders(:not_current_order_1)),
      create_order(orders(:not_current_order_2)),
      create_order(orders(:upcoming_order)),
      create_order(orders(:incoming_today)),
      create_order(orders(:outbound_today))]

    @orders_created.each do |order|
      @phone = create_phone(phones(:generic))
      @phone.orders << order
      order.mark_verified
      @ship = create_shipment(shipments(:generic), order, @phone)
      order.shipments << @ship
    end

    @orders = Order.currently_out
    assert @orders.any?{|order| order.invoice_id == "CURRENT1"} == true
    assert @orders.any?{|order| order.invoice_id == "CURRENT2"} == true
    assert @orders.any?{|order| order.invoice_id == "NOT_CURRENT1"} == false # future
    assert @orders.any?{|order| order.invoice_id == "NOT_CURRENT2"} == true # overdue
    assert @orders.any?{|order| order.invoice_id == "UPCOMING1"} == false
    assert @orders.any?{|order| order.invoice_id == "INCOMING_TODAY"} == true # not checked in yet
    assert @orders.any?{|order| order.invoice_id == "OUTBOUND_TODAY"} == true
  end

 test "orders which should be out but weren't marked shipped don't count as out" do
    @orders_created = [
      create_order(orders(:current_order)),
      create_order(orders(:current_order2))]

    @orders_created.each do |order|
      @phone = create_phone(phones(:generic))
      @phone.orders << order
      order.mark_verified # verified doesn't mean squat
    end

    @orders = Order.currently_out
    assert @orders.any?{|order| order.invoice_id == "CURRENT1"} == false
    assert @orders.any?{|order| order.invoice_id == "CURRENT2"} == false
  end

  # TODO: add test to check that received (individually) phones don't still display as incoming

  test "orders which are marked received no longer show as out" do
    @order = create_order(orders(:current_order))

    @phone = create_phone(phones(:generic))
    @phone.orders << @order
    @order.mark_verified
    @ship = create_shipment(shipments(:generic), @order, @phone)
    @order.shipments << @ship

    # order should still be out
    @orders = Order.currently_out
    assert @orders.any?{|o| o.invoice_id == "CURRENT1"} == true

    # check in back in    
    Order.mark_complete(@order.invoice_id)

    # order should be marked done
    @orders = Order.currently_out
    assert @orders.any?{|o| o.invoice_id == "CURRENT1"} == false
  end

  test "order shows up as out after being marked shipped" do
    @order = create_order(orders(:outbound_today))

    @phone = create_phone(phones(:generic))
    @phone.orders << @order
    @order.mark_verified

    # order should still be in
    @orders = Order.currently_out
    assert @orders.any?{|o| o.invoice_id == "OUTBOUND_TODAY"} == false

    # ship it out
    @ship = create_shipment(shipments(:generic), @order, @phone)
    @order.shipments << @ship

    # order should be marked as out
    @orders = Order.currently_out
    assert @orders.any?{|o| o.invoice_id == "OUTBOUND_TODAY"} == true
  end

  test "get orders between two dates" do
    @order_past2 = create_order(orders(:past2)) # 2 phones
    @order_past1 = create_order(orders(:past1)) # 2 phones
    @order_curr = create_order(orders(:current_order)) # 2 phones
    @order_future = create_order(orders(:upcoming_order)) # 2 phones

    # clear all other data
    @other_orders = Order.where.not(id:[
      @order_past2.id, 
      @order_past1.id,
      @order_curr.id,
      @order_future.id])
    @other_orders.destroy_all

    @orders = Order.between(@order_curr.arrival_date + 1, @order_curr.departure_date - 1) #2
    assert_equal(2, @orders.length)
    @orders = Order.between(@order_past2.arrival_date - 1, @order_past1.departure_date + 1) #3
    assert_equal(3, @orders.length)
    @orders = Order.between(@order_future.departure_date + 10, @order_past1.departure_date + 15) #3
    assert_equal(0, @orders.length)
  end

  test "extending an order correctly resolves phones" do
    @phone1 = create_phone(phones(:generic))
    @phone2 = create_phone(phones(:one))
    @phone3 = create_phone(phones(:two))
    @phone4 = create_phone(phones(:three))
    @phone5 = create_phone(phones(:four))

    @order1 = create_order(orders(:incoming_today)) # 2 phones
    @order1.brute_force_assign_phones

    @order2 = create_order(orders(:outbound_today)) # 2 phones
    @order2.brute_force_assign_phones

    @events = Event.joins(:order).group(:phone_id)
    .where("departure_date >= DATE(?) AND departure_date < DATE(?)", @order1.arrival_date, @order1.departure_date + 3)
    .having("max(events.created_at)")
    #puts "\n** ALL EVENTS ** #{@events.inspect}"
    
    # clear all other data
    @other_orders = Order.where.not(id:[
      @order1.id, 
      @order2.id])
    @other_orders.destroy_all

    @order1_phones = @order1.phone_ids
    @order2_phones = @order2.phone_ids
    assert_equal @order1_phones, @order2_phones

    #puts "\n******************\nMY ORDER IDS: #{@order1.id} #{@order2.id}"
    

    @order1.extend(@order2.arrival_date + 1)
    # refresh data
    @order1 = Order.find(@order1.id)
    @order2 = Order.find(@order2.id)
    @order1_phones = @order1.phone_ids
    @order2_phones = @order2.phone_ids

    # now check that its correct
    assert_not_equal @order1_phones, @order2_phones
  end

  test "extending an order correctly handles cases when no spare phones available" do
    @phone1 = create_phone(phones(:generic))
    @phone2 = create_phone(phones(:one))
    # clear all other phones
    @other_phones = Phone.where.not(id:[@phone1.id, @phone2.id])
    @other_phones.destroy_all

    @order1 = create_order(orders(:incoming_today)) # 2 phones
    @order1.brute_force_assign_phones
    @order2 = create_order(orders(:outbound_today)) # 2 phones
    @order2.brute_force_assign_phones

    # clear all other orders
    @other_orders = Order.where.not(id:[
      @order1.id, 
      @order2.id])
    @other_orders.destroy_all

    @order1_phones = @order1.phone_ids
    @order2_phones = @order2.phone_ids
    assert_equal @order1_phones, @order2_phones

    @exception = assert_raises(RuntimeError) { @order1.extend(@order2.arrival_date + 1) }
    assert_equal "No phones available", @exception.message
  end

  test "overdue orders detected" do
    @phone2 = create_phone(phones(:one))
    @phone1 = create_phone(phones(:two))
    @phone3 = create_phone(phones(:three))

    # on time
    @order1 = create_order(orders(:incoming_today))
    @order1.brute_force_assign_phones
    @order1.mark_verified
    @ship = create_shipment(shipments(:incoming_today), @order1, @phone)
    @order1.shipments << @ship

    # past due
    @order2 = create_order(orders(:past1))
    @order2.brute_force_assign_phones
    @order2.mark_verified
    @ship = create_shipment(shipments(:generic), @order2, @phone)
    @order2.shipments << @ship

    @overdue_orders = Order.overdue
    assert_equal 1, @overdue_orders.length
    assert_equal @order2.invoice_id, @overdue_orders[0].invoice_id
  end

  test "overdue shipping detected" do
    @phone2 = create_phone(phones(:one))
    @phone1 = create_phone(phones(:two))
    @phone3 = create_phone(phones(:three))

    @order1 = create_order(orders(:outbound_yesterday))
    @order1.brute_force_assign_phones
    @order1.mark_verified

    @order2 = create_order(orders(:outbound_today))
    @order2.brute_force_assign_phones
    @order2.mark_verified

    @overdue_orders = Order.overdue_shipping
    assert_equal 1, @overdue_orders.length
    assert_equal @order1.invoice_id, @overdue_orders[0].invoice_id
  end

  test "report missing phones due to not enough available phones after re-assignment" do
    @phone1 = create_phone(phones(:generic))
    @phone2 = create_phone(phones(:one))
    # clear all other phones
    @other_phones = Phone.where.not(id:[@phone1.id, @phone2.id])
    @other_phones.destroy_all

    @order1 = create_order(orders(:incoming_today)) # 2 phones
    @order1.brute_force_assign_phones
    @order2 = create_order(orders(:outbound_today)) # 2 phones
    @order2.brute_force_assign_phones

    # clear all other orders
    @other_orders = Order.where.not(id:[
      @order1.id, 
      @order2.id])
    @other_orders.destroy_all

    @order1_phones = @order1.phone_ids
    @order2_phones = @order2.phone_ids
    assert_equal @order1_phones, @order2_phones

    @exception = assert_raises(RuntimeError) { @order1.extend(@order2.arrival_date + 1) }

    @missing = Order.missing_phones
    assert_equal 1, @missing.length
    assert_equal @order2.invoice_id, @missing[0].invoice_id
  end

  # TODO: all warning together

end
