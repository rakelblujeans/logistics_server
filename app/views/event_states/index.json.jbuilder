json.array!(@event_states) do |event_state|
  json.extract! event_state, :id, :description
  json.url event_state_url(event_state, format: :json)
end
