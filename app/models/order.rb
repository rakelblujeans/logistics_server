class Order < ActiveRecord::Base
  belongs_to :customer
  has_many :shipments
  has_many :phones, through: :shipments
  has_many :receipts
  has_many :events

	# gets list of all unmatched orders
  def self.unmatched
    # TODO: once you hit 1000 orders you will notice performance degradation here
  	@state = EventState.find_or_create_by(description: "order received")
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