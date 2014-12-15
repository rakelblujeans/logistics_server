require 'test_helper'

class PhoneTest < ActiveSupport::TestCase

  test "available inventory is listed" do
		@arrival_date = Date.today
		@departure_date = Date.today + 3

  	@phones = Phone.available_inventory(@arrival_date, @departure_date)
  	@all_phones = Phone.all
  	assert @phones.length == @all_phones.length
  end

  test "upcoming orders is true" do
  	@phone = create_phone(phones(:generic))
  	@order = create_order(orders(:upcoming_order))
  	@phone.orders << @order
  	@orders = @phone.upcoming_orders
  	assert @orders.length == 1
	end

	test "upcoming order is false" do
  	@phone = create_phone(phones(:generic))
  	@order = create_order(orders(:current_order))
  	@phone.orders << @order
  	@orders = @phone.upcoming_orders
  	assert @orders.length == 0
  end

  test "order incoming today is true" do
  	@phone = create_phone(phones(:generic))
  	@order = create_order(orders(:incoming_today))
  	@phone.orders << @order
  	@order.mark_verified
		@ship = create_shipment(shipments(:incoming_today), @order, @phone)
  	@order.shipments << @ship

  	@orders = Phone.incoming_on(Date.today)
  	assert @orders.length == 1
  end

  test "order incoming today if false" do
  	 @phone = create_phone(phones(:generic))
  	@order = create_order(orders(:not_incoming_today))
  	@phone.orders << @order
  	@order.mark_verified
		@ship = create_shipment(shipments(:not_incoming_today), @order, @phone)
  	@order.shipments << @ship

  	@orders = Phone.incoming_on(Date.today)
  end

  test "outbound order today is true" do
  	@phone = create_phone(phones(:generic))
  	@order = create_order(orders(:outbound_today))
  	@phone.orders << @order
  	@order.mark_verified

  	@orders = Phone.outbound_on(Date.today)
  	assert @orders.length == 1
  end

  test "outbound order today is false" do
  	@phone = create_phone(phones(:generic))
  	@order = create_order(orders(:not_outbound_today))
  	@phone.orders << @order
  	@order.mark_verified

  	@orders = Phone.outbound_on(Date.today)
  	assert @orders.length == 0
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
  	@event = Phone.check_in(@phone.id)
  	assert @event.phone.id == @phone.id
	end
end
