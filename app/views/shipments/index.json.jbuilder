json.array!(@shipments) do |shipment|
  json.extract! shipment, :id, :delivery_out_code, :delivery_return_code, :hand_delivered_by, :qty, :out_on_date, :delivery_type, :order, :phones, :active
end
