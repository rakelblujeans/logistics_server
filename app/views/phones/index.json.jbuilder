json.array!(@phones) do |phone|
  json.extract! phone, :id, :inventory_id, :MEID, :ICCID, :phone_num, :notes, :last_imaged, :provider_id, :active, :shipments, :orders, :created_at, :updated_at
end
