json.array!(@event_states) do |event_state|
  json.extract! event_state, :id, :description
end
