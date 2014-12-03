class Order < ActiveRecord::Base
  belongs_to :customer
  has_many :shipments
  has_many :phones, through: :shipments
  has_many :receipts
  has_many :events

	# TODO: once you hit 1000 orders you will notice performance degradation here
  def self.unmatched
  	@state = EventState.where(description: "order received").first!
    @ids = []
    #logger.warn "HELOOOOO: #{@state.valid?}"
    @events = Event.group(:order_id).having("max(events.created_at)")
    @events.each do |event|
      if event.event_state_id == @state.id
        @ids << event.order_id
      end
    end

    @orders = Order.find(@ids)
  end


end