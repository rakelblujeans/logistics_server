json.array!(@delivery_types) do |delivery_type|
  json.extract! delivery_type, :id, :name
  json.url delivery_type_url(delivery_type, format: :json)
end
