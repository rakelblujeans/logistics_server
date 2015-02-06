class Event < ActiveRecord::Base
  belongs_to :customer
  belongs_to :order
  belongs_to :phone
  belongs_to :event_state

  # return one record per phone
  def self.filter_phone_events(state, max_date)
    @events = Event.group(:phone_id, 'events.id')
    .where("created_at <= DATE(?)", max_date)
    .where(event_state_id: state.id)
    .order("events.created_at DESC")
    @events
  end

  def self.filter_order_events(state, departure_date)
    @events = Event.joins(:order).group(:order_id, 'events.id').order("events.created_at DESC")
    .where("departure_date = DATE(?)", departure_date)
    @events
  end

end