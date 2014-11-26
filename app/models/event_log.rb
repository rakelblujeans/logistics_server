class EventLog < ActiveRecord::Base
  belongs_to :customer
  belongs_to :order
  belongs_to :event_state
end