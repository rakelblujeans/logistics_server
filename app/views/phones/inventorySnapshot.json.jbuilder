json.available_inventory do
 	json.array!(@available_inventory) do |phone|
  	json.extract! phone, :id, :inventory_id, :MEID, :ICCID, :phone_num, :notes, :last_imaged, :provider_id, :active, :created_at, :updated_at
	end
end

json.assignedInventory do
	json.array!(@assignedInventory) do |phone|
  	json.extract! phone, :id, :inventory_id, :MEID, :ICCID, :phone_num, :notes, :last_imaged, :provider_id, :active, :created_at, :updated_at
	end
end