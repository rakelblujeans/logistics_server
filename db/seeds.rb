# ruby encoding: utf-8

# Set up the simple data first. Everything else is based off these...

@p1 = Provider.create({name: 'Sprint/Kajeet', active: true});
@p2 = Provider.create({name: 'AT&T', active: true});

@languages = Language.create([
	{name: 'English'},
	{name: 'French'},
	{name: 'German'},
	{name: 'Japanese'},
	{name: 'Mandarin'},
	{name: 'Spanish'}
])

@event_states = EventState.create([
	{ description: 'inventory added' },
	{ description: 'order received' },
	{ description: 'order matched with inventory' },
	{ description: 'order assignment verified' },
	{ description: 'out for delivery' },
	{ description: 'received by customer' },
	{ description: 'sent out by customer' },
	{ description: 'inventory received by office' },
	{ description: 'deactivated' },
	]);

@dt1 = DeliveryType.create({name: 'Fedex'});
@dt2 = DeliveryType.create({name: 'UPS'});
@dt3 = DeliveryType.create({name: 'hand delivery'});
@dt4 = DeliveryType.create({name: 'unknown delivery method'});


# Now for the more complex data. Depends on one or more of the above...

@phones = Phone.addNew([
	{inventory_id: '01', MEID: '35823905652413', ICCID: '89011200000198262890', notes: "Raj's phone", last_imaged: '2014-10-01', provider:@p1, active: true},
	{inventory_id: '02', MEID: '352584060022552', notes: "Raquel's phone/Imaging", last_imaged: '2014-10-01', provider:@p1, active: true},
	{inventory_id: '08', MEID: '35823905766070', ICCID: '89011200000277619192', phone_num: '646-303-0170', notes: "Edward's phone", last_imaged: '2014-10-01', provider:@p1, active: true},
	{inventory_id: '04', MEID: '35823905766060', ICCID: '89011200000156277088', phone_num: '336-602-4072', last_imaged: '2014-10-23', provider:@p1, active: true},
	{inventory_id: '05', MEID: '35823905766864', ICCID: '89011200000156381757', phone_num: '336-602-8366', last_imaged: '2014-09-03', provider:@p1, active: true},
	{inventory_id: '06', MEID: '35823905766964', ICCID: '89011200000156301672', phone_num: '336-575-5083', last_imaged: '2014-10-27', provider:@p1, active: true},
	{inventory_id: '07', MEID: '35823905766971', ICCID: '89011200000156381724', phone_num: '336-602-4098', last_imaged: '2014-09-04', provider:@p1, active: true},
	{inventory_id: '09', MEID: '35823905766836', ICCID: '89011200000156381450', phone_num: '336-769-7394', last_imaged: '2014-10-30', provider:@p1, active: true},
	{inventory_id: '10', MEID: '35823905766841', ICCID: '89011200000156381419', phone_num: '336-422-2843', last_imaged: '2014-09-03', provider:@p1, active: true},
	{inventory_id: '11', MEID: '35823905766095', ICCID: '89011200000156381369', phone_num: '336-422-4262', last_imaged: '2014-09-19', provider:@p1, active: true},
	{inventory_id: '12', MEID: '35823905766870', ICCID: '89011200000156381856', phone_num: '336-602-9894', last_imaged: '2014-09-19', provider:@p1, active: true},
	{inventory_id: '13', MEID: '35823905922769', ICCID: '89011200000156276411', phone_num: '336-837-5400', last_imaged: '2014-10-23', provider:@p1, active: true},
	{inventory_id: '14', MEID: '35823905995898', ICCID: '89011200000156381526', phone_num: '336-837-5346', last_imaged: '2014-10-23', provider:@p1, active: true},
	{inventory_id: '15', MEID: '352584062527368', ICCID: '89011200000277619184', phone_num: '336-422-3516', last_imaged: '2014-10-01', provider:@p1, active: true},
	{inventory_id: '16', MEID: '35823905644679', ICCID: '89011200000156276437', phone_num: '336-695-6517', last_imaged: '2014-09-19', provider:@p1, active: true},
	{inventory_id: '17', MEID: '35823905908848', ICCID: '89011200000156298902', phone_num: '336-486-2795', last_imaged: '2014-09-12', provider:@p1, active: true},
	{inventory_id: '18', MEID: '35823905908511', ICCID: '89011200000156276478', phone_num: '917-304-7245', provider:@p1, active: true},
	{inventory_id: '19', MEID: '35823905916307', ICCID: '89011200000156276445', phone_num: '336-695-7103', last_imaged: '2014-08-08', provider:@p1, active: true},
	{inventory_id: '20', MEID: '35823905916045', ICCID: '89011200000156381534', phone_num: '336-624-5079', last_imaged: '2014-09-04', provider:@p1, active: true},
	{inventory_id: '21', MEID: '35823905992768', ICCID: '89011200000156361767', phone_num: '336-695-7628', last_imaged: '2014-10-01', provider:@p1, active: true},
	{inventory_id: '22', MEID: '35823905993146', ICCID: '89011200000156277104', phone_num: '336-602-7396', last_imaged: '2014-10-30', provider:@p1, active: true},
	{inventory_id: '23', MEID: '35823905992758', ICCID: '89011200000156381393', phone_num: '336-602-7348', last_imaged: '2014-10-27', provider:@p1, active: true},
	{inventory_id: '24', MEID: '35823905995903', ICCID: '89011200000196174485', phone_num: '336-624-2738', last_imaged: '2014-10-24', provider:@p1, active: true},
	{inventory_id: '25', MEID: '35823905993135', ICCID: '89011200000156275553', phone_num: '336-624-2517', last_imaged: '2014-10-13', provider:@p1, active: true},
	{inventory_id: '26', MEID: '35823905992761', ICCID: '89011200000156381377', phone_num: '336-602-9902', last_imaged: '2014-09-10', provider:@p1, active: true},
	{inventory_id: '27', MEID: '35823905993151', ICCID: '89011200000156381633', phone_num: '336-695-2267', last_imaged: '2014-09-12', provider:@p1, active: true},
	{inventory_id: '28', MEID: '35823905994394', ICCID: '89011200000156277070', phone_num: '336-602-5422', last_imaged: '2014-09-10', provider:@p1, active: true},
	{inventory_id: '29', MEID: '35823905992742', ICCID: '89011200000188017940', notes: 'With Alex Russo', provider:@p1, active: true},
	{inventory_id: '30', MEID: '35258406105947', ICCID: '89011200000277619267', phone_num: '336-577-4268', last_imaged: '2014-10-13', provider:@p1, active: true},
	{inventory_id: '31', MEID: '35823905917888', ICCID: '89011200000277619598', phone_num: '336-577-4112', last_imaged: '2014-10-13', provider:@p1, active: true},
	{inventory_id: '32', MEID: '35258406001922', ICCID: '89011200000277619580', phone_num: '336-354-9614', last_imaged: '2014-10-23', provider:@p1, active: true},
	{inventory_id: '33', MEID: '35258406002485', ICCID: '89011200000277619606', phone_num: '336-602-8346', last_imaged: '2014-08-07', provider:@p1, active: true},
	{inventory_id: '34', MEID: '35258406002319', ICCID: '89011200000277619150', phone_num: '336-354-9358', last_imaged: '2014-10-23', provider:@p1, active: true},
	{inventory_id: '35', MEID: '35823905917881', ICCID: '89011200000277619143', phone_num: '336-602-4057', last_imaged: '2014-10-30', provider:@p1, active: true},
	{inventory_id: '36', MEID: '35258406002447', ICCID: '89011200000277619259', phone_num: '336-624-3959', last_imaged: '2014-09-10', provider:@p1, active: true},
	{inventory_id: '37', MEID: '35258406002494', ICCID: '89011200000277619168', phone_num: '336-577-7880', last_imaged: '2014-10-24', provider:@p1, active: true},
	{inventory_id: '38', MEID: '35258406002342', ICCID: '89011200000277619176', phone_num: '336-624-0435', last_imaged: '2014-10-24', provider:@p1, active: true},
	{inventory_id: '39', MEID: '35258406002255', ICCID: '89014102255613602673', phone_num: '206-257-9278', provider: @p2, active: true},
	{inventory_id: '40', MEID: '35258406002482', provider:@p1, active: true},
	{inventory_id: '41', MEID: '35823905271817', ICCID: '89011200000222689738', phone_num: '336-695-2386', last_imaged: '2014-09-29', provider:@p1, active: true},
	{inventory_id: '42', MEID: '35258406167737', ICCID: '89011200000277619234', phone_num: '336-486-2239', last_imaged: '2014-10-31', provider:@p1, active: true},
	{inventory_id: '43', MEID: '352584062514481', ICCID: '89011200000222689415', phone_num: '336-695-2593', provider:@p1, active: true},
	{inventory_id: '44', MEID: '352584062530677', phone_num: '336-749-7279', provider: @p2, active: true},
	{inventory_id: '45', MEID: '352584062517757', phone_num: '336-749-7286', provider: @p2, active: true},
	{inventory_id: '46', MEID: '35258406251816', ICCID: '89011200000277619218', phone_num: '336-486-8243', last_imaged: '2014-10-30', provider:@p1, active: true},
	{inventory_id: '47', MEID: '35258406252729', ICCID: '89011200000277619200', phone_num: '336-486-8443', last_imaged: '2014-10-30', provider:@p1, active: true},
	{inventory_id: '48', MEID: '35258406252706', provider:@p2},
])

# estimated time spent in transit during delivery
@lead_time = Rails.configuration.delivery_transit_time_sending

# this is a past due order
@order6 = Order.addNew({
	invoice_id: 'IUY629',
	delivery_type_str: 'residential',
	full_address: '456 Main St',
	shipping_name: 'Mrs Past Due',
	shipping_city: 'new york',
	shipping_state: 'NY',
	shipping_zip: '67890',
	shipping_country: 'USA',
	shipping_apt_suite: '4C',
	shipping_notes: 'leave a note on the door',
	arrival_date: Date.today - 17,
	departure_date: Date.today - 7,
	language: 'en',
	num_phones: 1,
	active: true
	})
@order6.brute_force_assign_phones
@order6.mark_verified
@shipment6 = Shipment.addNew({
	active: true,
	delivery_out_code: "1Z9999999999999999",
	delivery_return_code: "1Z9999999999999999",
	out_on_date: @order6.arrival_date - @lead_time,
	order_id: @order6.id,
	phone_ids: @order6.phone_ids,
	qty: @order6.phones.count
	})



# this order is returning to our office today
@order2 = Order.addNew({
	invoice_id: '456FGH',
	delivery_type_str: 'residential',
	full_address: '123 Main St',
	shipping_name: 'Sally Jones',
	shipping_city: 'new york',
	shipping_state: 'NY',
	shipping_zip: '12345',
	shipping_country: 'USA',
	shipping_apt_suite: '4C',
	shipping_notes: 'leave a note on the door',
	arrival_date: Date.today - 7,
	departure_date: Date.today - 3,
	language: 'en',
	num_phones: 2,
	active: true
	})
@order2.brute_force_assign_phones
@order2.mark_verified
@shipment2 = Shipment.addNew({
	active: true,
	delivery_out_code: "1Z9999999999999999",
	delivery_return_code: "1Z9999999999999999",
	out_on_date: @order2.arrival_date - @lead_time,
	order_id: @order2.id,
	phone_ids: @order2.phone_ids,
	qty: @order2.phones.count
	})


# this should have shipped yesterday
@order7 = Order.addNew({
	invoice_id: 'MNB012',
	delivery_type_str: 'residential',
	full_address: '93 Cooper Lane',
	shipping_name: 'Mr Late Shipper',
	shipping_city: 'new york',
	shipping_state: 'NY',
	shipping_zip: '67890',
	shipping_country: 'USA',
	shipping_apt_suite: '4C',
	shipping_notes: 'leave a note on the door',
	arrival_date: Date.today + 2,
	departure_date: Date.today + 5,
	language: 'en',
	num_phones: 1,
	active: true
	})
@order7.brute_force_assign_phones
@order7.mark_verified

# this order is outbound tomorrow
@order1 = Order.addNew({
	invoice_id: 'XYZ123',
	delivery_type_str: 'residential',
	full_address: '123 Main St',
	shipping_name: 'Joe Smith',
	shipping_city: 'new york',
	shipping_state: 'NY',
	shipping_zip: '12345',
	shipping_country: 'USA',
	shipping_apt_suite: '4C',
	shipping_notes: 'leave a note on the door',
	arrival_date: Date.today + 4,
	departure_date: Date.today + 7,
	language: 'en',
	num_phones: 3,
	active: true
	})
@order1.brute_force_assign_phones
@order1.mark_verified

# this is a current order
@order3 = Order.addNew({
	invoice_id: '789LKO',
	delivery_type_str: 'residential',
	full_address: '456 Main St',
	shipping_name: 'Henry Collins',
	shipping_city: 'new york',
	shipping_state: 'NY',
	shipping_zip: '67890',
	shipping_country: 'USA',
	shipping_apt_suite: '4C',
	shipping_notes: 'leave a note on the door',
	arrival_date: Date.today - 7,
	departure_date: Date.today + 7,
	language: 'en',
	num_phones: 4,
	active: true
	})
@order3.brute_force_assign_phones
@order3.mark_verified
@shipment3 = Shipment.addNew({
	active: true,
	delivery_out_code: "1Z9999999999999999",
	delivery_return_code: "1Z9999999999999999",
	out_on_date: @order3.arrival_date - @lead_time,
	order_id: @order3.id,
	phone_ids: @order3.phone_ids,
	qty: @order3.phones.count
	})

@order5 = Order.addNew({
	invoice_id: '789SDF',
	delivery_type_str: 'residential',
	full_address: '456 Main St',
	shipping_name: 'Billy Bob',
	shipping_city: 'new york',
	shipping_state: 'NY',
	shipping_zip: '67890',
	shipping_country: 'USA',
	shipping_apt_suite: '4C',
	shipping_notes: 'leave a note on the door',
	arrival_date: Date.today + 16,
	departure_date: Date.today + 20,
	language: 'en',
	num_phones: 4,
	active: true
	})
@order5.brute_force_assign_phones

# this one has one phone missing
@order4 = Order.addNew({
	invoice_id: '345BUQ',
	delivery_type_str: 'residential',
	full_address: '456 Main St',
	shipping_name: 'Patsy Fonseca',
	shipping_city: 'new york',
	shipping_state: 'NY',
	shipping_zip: '67890',
	shipping_country: 'USA',
	shipping_apt_suite: '4C',
	shipping_notes: 'leave a note on the door',
	arrival_date: Date.today + 10,
	departure_date: Date.today + 14,
	language: 'en',
	num_phones: 4,
	active: true
	})
@order4.brute_force_assign_phones
@order4.phones.delete(@order4.phones[0])