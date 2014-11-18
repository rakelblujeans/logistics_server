json.array!(@providers) do |provider|
  json.extract! provider, :id, :name, :active
  json.url provider_url(provider, format: :json)
end
