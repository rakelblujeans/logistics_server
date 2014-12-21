class Event < ActiveRecord::Base
  belongs_to :customer
  belongs_to :order
  belongs_to :phone
  belongs_to :event_state

  # return one record per phone
  def self.filterByState(state, max_date)
    @ids = []
    @events = Event.group(:phone_id)
    .where("events.created_at <= DATE(?)", max_date)
    .where(event_state_id: state.id)
    .having("max(events.created_at)")
  end

=begin
  def self.lastEventForPhone(phone_id, max_date)
    @event = Event.group(:phone_id)
    .where(phone_id: phone_id)
    .where("events.created_at <= DATE(?)", max_date)
    .having("max(events.created_at)").first!
    return @event
  rescue ActiveRecord::RecordNotFound
    return nil
  end
=end

end