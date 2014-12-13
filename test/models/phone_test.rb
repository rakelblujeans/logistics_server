require 'test_helper'

class PhoneTest < ActiveSupport::TestCase

  test "available inventory" do
		@arrival_date = Date.today
		@departure_date = Date.today + 3

  	@phones = Phone.available_inventory(@arrival_date, @departure_date)
  	@all_phones = Phone.all
  	assert @phones.length == @all_phones.length
  end

  test "upcoming orders" do
  	@phone = create_phone(phones(:one))
  	@order = create_order(orders(:upcoming_order))
  	@phone.orders << @order
  	@orders = @phone.upcoming_orders
  	assert @orders.length == 1

  	@phone = create_phone(phones(:two))
  	@order = create_order(orders(:current_order))
  	@phone.orders << @order
  	@orders = @phone.upcoming_orders
  	assert @orders.length == 0
  end

  test "incoming on" do
  	@phone = create_phone(phones(:one))
  	@order = create_order(orders(:incoming_today))
  	@phone.orders << @order
  	@order.mark_verified
		@ship = create_shipment(shipments(:incoming_today), @order, @phone)
  	@order.shipments << @ship

  	@orders = Phone.incoming_on(Date.today)
  	assert @orders.length == 1
  end

  test "outbound on" do
  	@phone = create_phone(phones(:one))
  	@order = create_order(orders(:outbound_today))
  	@phone.orders << @order
  	@order.mark_verified

  	@orders = Phone.outbound_on(Date.today)
  	assert @orders.length == 1
  end

  test "current order" do
  	@phone = create_phone(phones(:one))
  	@order = create_order(orders(:current_order))
  	@phone.orders << @order

  	@order = @phone.current_order
  	assert_not_nil @order
	end

	test "check in" do
		@phone = create_phone(phones(:one))
  	@event = Phone.check_in(@phone.id)
  	assert @event.phone.id == @phone.id
	end
end
