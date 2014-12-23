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

  def self._fix_departure_date(in_date)
    if self.string? in_date
      in_date.gsub! "/", "-"
      in_date = Date.strptime(in_date, "%Y-%m-%d")
    end
    @return_transit_time = 3
    @departure_date = in_date - @return_transit_time

    # convert back to string
    @departure_date = @departure_date.strftime("%Y-%m-%d")
  end

  def self._fix_arrival_date(in_date)
    # if string, convert to date object
    if self.string? in_date
      in_date.gsub! "/", "-"
      in_date = Date.strptime(in_date, "%Y-%m-%d")
    end

    # [date customer needs phone] - [time spent in transit] 
    # = estimated departure date from our office
    @leading_transit_time = 3
    @real_date = in_date + @leading_transit_time

    # convert back to string
    @real_date.change({ hour: 0, min: 0, sec: 0 })
    @real_date = @real_date.strftime("%Y-%m-%d")
  end

#########

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

        @state = EventState.order_received
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
    @state_received = EventState.order_received
    @state_matched = EventState.matched_inventory
    @state_unmatched = EventState.unassigned_inventory
    @ids = []
    @events = Event.group(:order_id).having("max(events.created_at)")
    @events.each do |event|
      if event.event_state_id == @state_received.id || 
        event.event_state_id == @state_matched.id ||
        event.event_state_id == @state_unmatched.id
        @ids << event.order_id
      end
    end

    @orders = Order.find(@ids)
  end

  # gets list of all unverified orders
  def self.verified
    @state_verified = EventState.order_verified
    @ids = []
    @events = Event.group(:order_id).having("max(events.created_at)")
    @events.each do |event|
      if event.event_state_id == @state_verified.id
        @ids << event.order_id
      end
    end

    @orders = Order.find(@ids)
  end

  # what phones arrive in our office on this date?
  def self.incoming_on(in_date)
    @departure_date = self._fix_departure_date(in_date)
    #
    # NOTE: since we are not tracking Fedex/delivery events, 
    # just go off order's departure date & the fact that we
    # delivered some inventory. Not optimal!
    @state_inventory_sent = EventState.inventory_delivered
    @order_ids = []
    @events = Event.filter_order_events(@state_inventory_sent, @departure_date)
    @events.each do |event|
      if event.event_state_id == @state_inventory_sent.id
        @order_ids << event.order_id
      end
    end

    @data = []
    @state_inventory_received = EventState.received_inventory
    @in_date_bracket = Date.today + 1
    @received_phone_ids = Event.filter_phone_events(@state_inventory_received, @in_date_bracket).pluck(:phone_id)
    # these are phones out in the field, due today
    @orders = Order.joins(:phones).where(id: @order_ids).group(:order_id)
    @orders.each do |order|
      # subtract phones that have already been checked back in
      @incoming_phones = Array.new(order.phones.all)
      @incoming_phones.delete_if { |phone| @received_phone_ids.include? phone.id }
      if @incoming_phones.length > 0
        @data << {
          order_id: order.id,
          invoice_id: order.invoice_id,
          incoming_phones: @incoming_phones }
      end
    end
    return @data
  end

  # what phones leave our office on this date?
  def self.outbound_on(in_date)
    @real_date = self._fix_arrival_date(in_date)
    # only consider orders that we have manually verified
    # as "shippable" and orders that may only be partially shipped
    @event_order_verified = EventState.order_verified
    @estate_delivered = EventState.inventory_delivered
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
      @unshipped_phones = Array.new(order.phones.all)
      order.shipments.each do |shipment|
        shipment.phones.each do |phone|
          @unshipped_phones.delete phone
        end
      end
      if @unshipped_phones.length > 0
        @data << 
          { order_id: order.id,
          invoice_id: order.invoice_id,
          unshipped_phones: @unshipped_phones }
      end
    end

    return @data
  end

  def self.mark_complete(invoice_id)
    @order = Order.where(invoice_id: invoice_id).last!
    @phones_copy = Array.new(@order.phones_still_out)
    
    @phones_copy.each do |phone|
      Phone.check_in(phone.inventory_id)
    end

    @state_completed = EventState.order_completed
    Event.create({
      event_state_id: @state_completed.id,
      order_id: @order.id
      })
    @order
  end

  def self.overdue
    @events = Event.joins(:order).group(:order_id)
    .having("max(events.created_at)")
    .where("date(departure_date, '+3 days') <= DATE(?)", Date.today)

    @order_ids = []
    @events.each do |event|
      if event.event_state_id == @state_inventory_sent.id
        @order_ids << event.order_id
      end
    end

    @orders = Order.where(id:@order_ids)
  end

  def self.currently_out
    # NOTE: since we are not tracking Fedex/delivery events, 
    # just go off order's departure date & the fact that we
    # delivered some inventory. Not optimal!
    @today = Date.today
    @state_inventory_sent = EventState.inventory_delivered
    @order_ids = []

    # orders currently out
    @events = Event.joins(:order).group(:order_id).having("max(events.created_at)")
    .where("date(arrival_date, '-3 days') <= DATE(?) AND date(departure_date, '+3 days') > DATE(?)", 
      @today, @today)
    
    @events.each do |event|
      if event.event_state_id == @state_inventory_sent.id
        @order_ids << event.order_id
      end
    end
  
    # orders overdue
    @order_ids << Order.overdue.pluck(:id)

    @orders = Order.where(id:@order_ids)
  end

  # gets ALL orders between these two dates, regardless of state
  def self.between(date1, date2)
    # if date object, convert to string
    if self.date? date1
      date1 = date1.strftime("%Y-%m-%d")
    end
    if self.date? date2
      date2 = date2.strftime("%Y-%m-%d")
    end

    @orders = Order.where("(DATE(?) <= date(arrival_date, '-3 days') AND date(arrival_date, '-3 days') < DATE(?)) OR (DATE(?) <= date(departure_date, '+3 days') AND date(departure_date, '+3 days') < DATE(?))",
      date1, date2, date1, date2)
  end

#########

  def mark_verified
    @state = EventState.order_verified
    @event = Event.create(
      order_id: self.id,
      event_state_id: @state.id)
  end

  def is_verified
    @state = EventState.order_verified
    @event = Event.where(
      order_id: self.id,
      event_state_id: @state.id).last!
    return true
  rescue ActiveRecord::RecordNotFound
    return false
  end

  def assign_device(phone_id)
    Order.transaction do
      @phone = Phone.where(id: phone_id).last!
      self.phones << @phone

      @state = EventState.matched_inventory
      Event.create(
        event_state_id: @state.id,
        phone_id: @phone.id,
        order_id: self.id)
    end
    @order
  end

  def unassign_device(phone_id)
    @did_unassign = false
    Order.transaction do
      @found_phone = self.phones.where(id: phone_id).first
      if @found_phone
        self.phones.delete(@found_phone)
        @state_unassigned = EventState.unassigned_inventory
        Event.create(
          event_state_id: @state_unassigned.id,
          phone_id: @found_phone.id,
          order_id: self.id)
        @did_unassign = true
        break
      end

      #self.phones.each do |phone|
      #  if phone.id == phone_id.to_i
      #  end
      #end

      # update recorded events
      # TODO: don't do this
      #@state = EventState.matched_inventory
      #@event = Event.where(
      #  order_id: self.id,
      #  phone_id: phone_id,
      #  event_state_id: @state.id).first!
      #if @event != nil
      #  @event.destroy
      #end
    end
    @did_unassign
  end

  # TODO: not optimal!
  def brute_force_assign_phones

    # TODO: error checking
    @assigned_ids = nil
    Order.transaction do
      # get list of available phones, assign all open slots
      @phones = Phone.available_inventory(self.arrival_date-3, self.departure_date+3)
      @phones_idx = 0
      #puts "\n\n **** AVAILABLE[#{self.invoice_id}]: #{@phones.ids.inspect}"
      if @phones.empty?
        #puts "***** No phones available! *****"
        raise "No phones available"
      end
      @assigned_ids = Array.new(self.num_phones)
      (0..self.num_phones-1).each do |i|
        if !self.phones[i]
          #puts "\t ASSIGNING #{@phones[@phones_idx].id}"
          @assigned_ids.push(@phones[@phones_idx].id)
          
          # log the event in our history
          @state = EventState.matched_inventory
          @event = Event.create({
              event_state_id: @state.id,
              phone_id: @phones[@phones_idx].id,
              order_id: self.id
            })

          @phones_idx += 1
        else
          #puts "**** SLOT HAS phone #{self.phones[i].id}"
          @assigned_ids.push(self.phones[i].id)
        end
      end
      self.phone_ids = @assigned_ids
    end
    @assigned_ids
  end

  def phones_still_out
    @in_date_bracket = (Time.now.utc + 1.day).midnight
    @state_inventory_received = EventState.received_inventory
    @received_phone_ids = Event.filter_phone_events(@state_inventory_received, @in_date_bracket).pluck(:phone_id)
    # subtract phones that have already been checked back in
    @incoming_phones = Array.new(self.phones.all)
    @incoming_phones.delete_if { |phone| @received_phone_ids.include? phone.id }
    @incoming_phones
  end

  def extend(new_departure_date)
    if new_departure_date.kind_of?(Date)
      new_departure_date = new_departure_date.strftime("%Y-%m-%d")
    end
    
    @old_departure_date = self.departure_date
    self.update(departure_date: new_departure_date)

    @my_phones = self.phones

    # find out which orders could be in conflict
    #puts "\nORDER IS NOW #{self.arrival_date} #{self.departure_date}"
    @orders = Order.between(@old_departure_date, new_departure_date)
    @orders.each do |order|
      # skip ourselves
      if order.id == self.id
        next
      end

      #puts "CONFLICTING ORDER IS #{order.arrival_date} #{order.departure_date}"
      @my_phones.each do |conflicting_phone|
        #puts "\nUNASSIGNING order[#{order.id}] #{conflicting_phone.id}"
        if order.unassign_device(conflicting_phone.id)
          #puts "\nNOW REASSIGN!"
          order.brute_force_assign_phones
        end
      end
    end

  end

end