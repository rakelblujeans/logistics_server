json.array!(@orders) do |order|
  json.extract! order, :id, :invoice_id, :delivery_type_str, 
  	:full_address, :shipping_name, :shipping_city, :shipping_state, :shipping_zip, :shipping_country, :shipping_apt_suite, :shipping_notes, :arrival_date, :departure_date, :language, :num_phones, :active, :events, :phones, :shipments, :created_at, :updated_at
end

