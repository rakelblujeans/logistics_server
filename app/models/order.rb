class Order < ActiveRecord::Base
  belongs_to :customer
  has_many :shipments
  #has_many :phones, through: :shipments
  has_and_belongs_to_many :phones
  has_many :receipts
  has_many :events

  def self.date?(obj)
    obj.kind_of?(Date)
  end

  def self.string?(obj)
    obj.kind_of?(String)
  end


  def self.addNewHelper(order_params)
    
    begin
      @order = nil
      Order.transaction do
        order_params["active"] = true

        if self.string? order_params["arrival_date"]
          order_params["arrival_date"].gsub! "/", "-"
        end
        if self.string? order_params["departure_date"]
          order_params["departure_date"].gsub! "/", "-"
        end
        @order = Order.new(order_params)
        @order.save

        @state = EventState.orderReceived
        @event = Event.create(
          event_state: @estate,
          order_id: @order.id)
        # assign phones
        # TODO: dumb assignment for now, needs optimization
        #@order.brute_force_assign_phones
      end
      @order
    rescue ActiveRecord::StatementInvalid
      return nil
    end
  end

  def self.addNew(attributes = nil)
    if attributes.is_a?(Array)
      attributes.collect { |attr| self.addNewHelper(attr) }
    else
      #puts "**** #{@attributes.inspect}"
      object = self.addNewHelper(attributes)
      yield(object) if block_given?
      object
    end
  end

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

  # gets list of all unverified orders
  def self.verified
    @state_verified = EventState.orderVerified
    @ids = []
    @events = Event.group(:order_id).having("max(events.created_at)")
    @events.each do |event|
      if event.event_state_id == @state_verified.id
        @ids << event.order_id
      end
    end

    @orders = Order.find(@ids)
  end

  def assign_device(phone_id)
    Order.transaction do
      @phone = Phone.where(id: phone_id).first!
      self.phones << @phone

      @state = EventState.matchedInventory
      Event.create(
        event_state_id: @state.id,
        phone_id: @phone.id,
        order_id: self.id)
    end
    @order
  end

  def unassign_device(phone_id)
    Order.transaction do
      self.phones.each do |phone|
        if phone.id == phone_id.to_i
          self.phones.delete(phone)
          break
        end
      end

      # update recorded events
      @state = EventState.matchedInventory
      @event = Event.where(
        order_id: self.id,
        phone_id: phone_id,
        event_state_id: @state.id).first!
      if @event != nil
        @event.destroy
      end
    end
  end

  # TODO: not optimal!
  def brute_force_assign_phones
    #TODO: error checking
    @assigned_ids = nil
    Order.transaction do
      # get list of available phones, assign all open slots
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
    end
    @assigned_ids
  end

  def mark_verified
    Order.transaction do
      @state = EventState.orderVerified
      @event = Event.create(
        order_id: self.id,
        event_state_id: @state.id)
    end
  end

end