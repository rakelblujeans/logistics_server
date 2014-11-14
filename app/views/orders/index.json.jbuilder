json.array!(@orders) do |order|
  json.extract! order, :id, :delivery_type_str, 
  	:full_address, :shipping_name, :shipping_city, :shipping_state, :shipping_zip, :shipping_country, :shipping_apt_suite, :shipping_notes, :arrival_date, :departure_date, :language, :num_phones
  json.url order_url(order, format: :json)
end
