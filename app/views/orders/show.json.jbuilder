json.extract! @order, :id, :delivery_type_str, :invoice_id,
	:full_address, :shipping_name, :shipping_city, :shipping_state, :shipping_zip, :shipping_country, :shipping_apt_suite, :shipping_notes, :arrival_date, :departure_date, :language, :num_phones, :active, :created_at, :updated_at, :events, :phones
json.shipments @order.shipments do |shipment|
  json.extract! shipment, :id, :delivery_out_code, 
		:delivery_return_code, :hand_delivered_by, :qty, :active, :out_on_date, :delivery_type, :phones
end
json.is_verified @is_verified