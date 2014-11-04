json.array!(@orders) do |order|
  json.extract! order, :id, :order_state, :delivery_type, :full_address, :shipping_name, :shipping_city, :shipping_state, :shipping_zip, :shipping_country, :shipping_apt_suite, :shipping_notes, :arrival_date, :departure_date, :language, :num_phones, :fedex_out_code, :fedex_return_code, :customer_id, :phone_id
  json.url order_url(order, format: :json)
end
