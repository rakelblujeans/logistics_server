class Order < ActiveRecord::Base
  belongs_to :customer
  has_many :shipments
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
        order_params[:active] = true

        if self.string? order_params[:arrival_date]
          order_params[:arrival_date].gsub! "/", "-"
        #else 
        #  order_params[:arrival_date].change({ hour: 0, min: 0, sec: 0 })
        end
        if self.string? order_params[:departure_date]
          order_params[:departure_date].gsub! "/", "-"
        #else
        #  order_params[:departure_date].change({ hour: 0, min: 0, sec: 0 })
        end
        @order = Order.new(order_params)
        @order.save

        @state = EventState.orderReceived
        @event = Event.create(
          event_state: @state,
          order_id: @order.id)
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

  def mark_verified
    @state = EventState.orderVerified
    @event = Event.create(
      order_id: self.id,
      event_state_id: @state.id)
  end

  def is_verified
    @state = EventState.orderVerified
    @event = Event.where(
      order_id: self.id,
      event_state_id: @state.id).first!
    return true
  rescue ActiveRecord::RecordNotFound
    return false
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
      #puts "#{@phones.inspect}"
      if @phones.empty?
        logger.error "No phones available!"
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

  
  # what phones leave our office on this date?
  def self.outbound_on(in_date)
    #logger.debug "IN DATE: #{in_date}"
    # if string, convert to date object
    if self.string? in_date
      in_date.gsub! "/", "-"
      in_date = Date.strptime(in_date, "%Y-%m-%d")
      #in_date.change({ hour: 0, min: 0, sec: 0 })
    end
    #in_date = in_date.utc
    #in_date.change({ hour: 0, min: 0, sec: 0 })

    # [date customer needs phone] - [time spent in transit] 
    # = estimated departure date from our office
    @leading_transit_time = 3
    @real_date = in_date + @leading_transit_time
    #logger.debug "**** #{in_date} #{@real_date}"

    # convert back to string
    @real_date.change({ hour: 0, min: 0, sec: 0 })
    @real_date = @real_date.strftime("%Y-%m-%d")

    # only consider orders that we have manually verified
    # as "shippable" and orders that may only be partially shipped
    @event_order_verified = EventState.orderVerified
    @estate_delivered = EventState.inventoryDelivered
    @order_ids = []
    @events = Event.joins(:order).group(:order_id).having("max(events.created_at)")

    @events.each do |event|
      if event.event_state_id == @event_order_verified.id ||
        event.event_state_id == @estate_delivered.id
        @order_ids << event.order_id
      end
    end
    
    @data = []
    @outbound_orders = Order.joins(:phones).group(:order_id)
    .where(id: @order_ids)
    .where('arrival_date == DATE(?)', @real_date).all
    @outbound_orders.each do |order|
      @unshippedPhones = Array.new(order.phones.all)
      order.shipments.each do |shipment|
        shipment.phones.each do |phone|
          @unshippedPhones.delete phone
        end
      end
      @data << 
        { order_id: order.id,
        invoice_id: order.invoice_id,
        unshipped_phones: @unshippedPhones}
    end

    return @data
  end

end