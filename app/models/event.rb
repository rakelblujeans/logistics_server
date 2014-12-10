class Event < ActiveRecord::Base
  belongs_to :customer
  belongs_to :order
  belongs_to :phone
  belongs_to :event_state

   def self.filterOrdersByState(state)
    @ids = []
    @events = Event.group(:order_id).having("max(events.created_at)")
    @events.each do |event|
      if event.event_state_id == state.id
        @ids << event.order_id
      end
    end

    @orders = Order.find(@ids)
  end

end