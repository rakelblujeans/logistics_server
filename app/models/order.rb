class Order < ActiveRecord::Base
  belongs_to :customer
  has_many :shipments
  #has_many :phones, through: :shipments
  has_and_belongs_to_many :phones
  has_many :receipts
  has_many :events

  # gets list of all unverified orders
  def self.unverified
    @state_received = EventState.orderReceived
    @state_matched = EventState.matchedInventory
    @ids = []
    @events = Event.group(:order_id).having("max(events.created_at)")
    @events.each do |event|
      if event.event_state_id == @state_received.id || 
        event.event_state_id == @state_matched.id
        @ids << event.order_id
      end
    end

    @orders = Order.find(@ids)
  end

=begin
	# gets list of all unmatched orders
  def self.unmatched
    # TODO: once you hit 1000 orders you will notice performance degradation here
  	@state = EventState.orderReceived
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
=end

  # TODO: fix. not optimal!
  def brute_force_assign_phones
    #TODO: error checking, wrap in transaction

    # get list of available phones, assign all open slots
    #logger.debug("***** " + self.inspect)
    @phones = Phone.available_inventory(self.arrival_date, self.departure_date)
    if @phones.empty?
      logger.debug "No phones available!"
      return []
    end

    @assigned_ids = Array.new(self.num_phones)
    (1..self.num_phones).each do |i|
      if !self.phones[i]
        @assigned_ids.push(@phones[i].id)

        # log the event in our history
        @state = EventState.matchedInventory
        @event = Event.create({
            event_state_id: @state.id,
            phone_id: @phones[i].id,
            order_id: self.id
          })
      end
    end
    self.phone_ids = @assigned_ids
    return @assigned_ids
  end

end