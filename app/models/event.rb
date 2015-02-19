class Event < ActiveRecord::Base
  belongs_to :order
  belongs_to :phone
  belongs_to :event_state

  # return one record per phone
  def self.filter_phone_events(state, max_date)
    @events = Event.latest_per_phone
     .where("events.created_at < DATE(?)", max_date)
     .where(event_state_id: state.id)
    @events
  end

  def self.filter_order_events(state, departure_date)
    #@events = Event.joins(:order).group(:order_id, 'events.id').order("events.created_at DESC")
    @events = Event.latest_per_order
    .joins(:order)
    .where("orders.departure_date = DATE(?)", departure_date)
    @events
  end

  def self.latest_per_phone
    @events = Event.select("DISTINCT ON (phone_id) events.*")
      .where('events.phone_id IS NOT NULL')
      .order('events.phone_id, events.created_at DESC');
  end

  # add test
  def self.latest_per_order
    # SELECT DISTINCT ON (order_id) * FROM events WHERE order_id IS NOT NULL ORDER BY order_id, created_at DESC;
    @events = Event.select("DISTINCT ON (order_id) events.*")
      .where('events.order_id IS NOT NULL')
      .order('events.order_id, events.created_at DESC');
  end

end