json.array!(@customers) do |customer|
  json.extract! customer, :id, :fname, :lname, :email, :bt_id, :active
  json.url customer_url(customer, format: :json)
end
