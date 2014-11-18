json.array!(@shipments) do |shipment|
  json.extract! shipment, :id, :fedex_out_code, :fedex_return_code, :qty, :active
  json.url shipment_url(shipment, format: :json)
end
