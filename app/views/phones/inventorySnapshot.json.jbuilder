json.availableInventory do
 	json.array!(@availableInventory) do |phone|
  	json.extract! phone, :id, :inventory_id, :MEID, :ICCID, :phone_num, :notes, :last_imaged, :provider_id, :active, :created_at, :updated_at
	end
end

json.assignedInventory do
	json.array!(@assignedInventory) do |phone|
  	json.extract! phone, :id, :inventory_id, :MEID, :ICCID, :phone_num, :notes, :last_imaged, :provider_id, :active, :created_at, :updated_at
	end
end