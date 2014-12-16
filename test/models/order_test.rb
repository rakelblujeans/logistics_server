require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  
  test "unverified order passes unverified check" do
  	@order = create_order(orders(:generic))
  	assert Order.unverified.length == 1
  end

  test "unverified order fails verified check" do
  	@order = create_order(orders(:generic))
  	assert Order.verified.length == 0
  end

  test "mark order verified" do
  	@order = create_order(orders(:generic))
  	@order.mark_verified
  	assert Order.unverified.length == 0
  	assert Order.verified.length == 1
  end

  test "assign device" do
  	@phone = create_phone(phones(:generic))
  	@order = create_order(orders(:generic))
  	@order.assign_device(@phone.id)

  	assert @order.phones[0].id == @phone.id
  	assert @order.events[@order.events.length - 1].event_state_id == EventState.matchedInventory.id
	end

	test "unassign device" do
  	@phone = create_phone(phones(:generic))
  	@order = create_order(orders(:generic))
  	@order.assign_device(@phone.id)
  	@order.unassign_device(@phone.id)

		assert @order.phones.length == 0
  	assert @order.events[@order.events.length - 1].event_state_id != EventState.matchedInventory.id
	end

	test "brute force assign phone" do
		@phone1 = create_phone(phones(:generic))
		@phone2 = create_phone(phones(:generic))
		@phone3 = create_phone(phones(:generic))
  	@order = create_order(orders(:generic))
  	@order.brute_force_assign_phones

  	assert @order.phones.length == @order.num_phones
  	@events = Event.where(event_state_id: EventState.matchedInventory.id)
  	assert @events.length == @order.num_phones
	end

  test "overlapping orders get assigned different phones" do
    @phone1 = create_phone(phones(:generic))
    @phone2 = create_phone(phones(:one))
    @phone3 = create_phone(phones(:two))
    @order1 = create_order(orders(:current_order))
    @order1.brute_force_assign_phones

    @order2 = create_order(orders(:incoming_today))
    @order2.brute_force_assign_phones

    assert @order1.phones.length == @order1.num_phones
    assert @order2.phones.length == @order2.num_phones
    assert_not_equal @order1.phones, @order2.phones
  end


end
