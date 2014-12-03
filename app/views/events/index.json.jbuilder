json.array!(@events) do |event|
  json.extract! event, :id, :event_state, :order, :customer, :phone, :created_at, :updated_at
end
