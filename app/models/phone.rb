class Phone < ActiveRecord::Base
  belongs_to :provider
  has_and_belongs_to_many :shipments
  has_and_belongs_to_many :orders

  def self.date?(obj)
    obj.kind_of?(Date)
  end

  def self.string?(obj)
    obj.kind_of?(String)
  end

  # adds one new phones
  def self.addNewHelper(phone_params)
    begin
      @phone = nil
      Phone.transaction do
        @phone = Phone.new(phone_params)
        @phone.save

        @estate = EventState.inventoryAdded
        @event = Event.create(
          event_state: @estate,
          phone_id: @phone.id)
      end
      @phone
    rescue ActiveRecord::StatementInvalid
      return @phone
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

  # list of inventory available for assignment during 
  # this data range
  # expects dates as UTC YYYY-MM-DD (no slashes)
  def self.available_inventory(in_start, in_end)
    # sanity check
    if !in_start || !in_end
      return []
    end

    if self.string? in_start
      in_start.gsub! "/", "-"
      in_start = Date.strptime(in_start, "%Y-%m-%d")
      #in_date.change({ hour: 0, min: 0, sec: 0 })
    end
    
    if self.string? in_end
      in_end.gsub! "/", "-"
      in_end = Date.strptime(in_end, "%Y-%m-%d")
      #in_date.change({ hour: 0, min: 0, sec: 0 })
    end

    # add padding for lead times
    @lead_time = 3
    @start_date = in_start - @lead_time
    @end_date = in_end + @lead_time


    # convert date objects into strings
    #if self.date? in_start
      #in_start.change({ hour: 0, min: 0, sec: 0 })
      in_start = in_start.strftime("%Y-%m-%d")
    #end

    #if self.date? in_end
      #in_end.change({ hour: 0, min: 0, sec: 0 })
      in_end = in_end.strftime("%Y-%m-%d")
    #end
    
    @events = Event.joins(:order).group(:phone_id)
    .where("(DATE(?) <= arrival_date AND arrival_date < DATE(?)) OR (DATE(?) <= departure_date AND departure_date < DATE(?))", 
      @start_date, @end_date, @start_date, @end_date)
    .having("max(events.created_at)")

    @used_phone_ids = []
    @state_matched = EventState.matchedInventory
    @events.each do |event|
      if event.event_state_id == @state_matched.id
        @used_phone_ids << event.phone_id
      end
    end

    # return the complement of that set
    @phones = Phone.where.not(id:@used_phone_ids).order(:inventory_id)
  end

  def upcoming_orders
    @upcoming_orders = []
    today = Date.today
    @transit_time = 3
    self.orders.each do |order|
      if order.arrival_date > today + @transit_time
        @upcoming_orders << order
      end
    end

    return @upcoming_orders
  end

  # what phones arrive in our office on this date?
  def self.incoming_on(in_date)
    # if string, convert to date object

    if self.string? in_date
      in_date.gsub! "/", "-"
      in_date = Date.strptime(in_date, "%Y-%m-%d")
    end
    in_date.change({ hour: 0, min: 0, sec: 0 })
    @in_date_bracket = in_date + 1
    # [date customer sent out phone] + [time spent in transit] 
    # = estimated arrival date in our office
    @return_transit_time = 3
    @departure_date = in_date - @return_transit_time

    # convert back to string
    @departure_date = @departure_date.strftime("%Y-%m-%d")

    # NOTE: since we are not tracking Fedex/delivery events, 
    # just go off order's departure date & the fact that we
    # delivered some inventory. Not optimal!
    @state_inventory_sent = EventState.inventoryDelivered
    @order_ids = []
    @events = Event.joins(:order).group(:order_id).having("max(events.created_at)")
    .where("departure_date = DATE(?)", @departure_date)
    @events.each do |event|
      if event.event_state_id == @state_inventory_sent.id
        @order_ids << event.order_id
      end
    end

    # these are phones out in the field, due today
    @phone_ids = Order.joins(:phones).where(id: @order_ids).pluck(:phone_id)

    # subtract phones that have already been checked back in
    @state_inventory_received = EventState.receivedInventory
    @received_phone_ids = Event.filterByState(@state_inventory_received, @in_date_bracket).pluck(:phone_id)
    
    @phone_ids.delete_if { |id| @received_phone_ids.include? id }
    # return the final list
    @phones = Phone.where(id: @phone_ids)
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
    # as "shippable"
    @event_order_verified = EventState.orderVerified
    @order_ids = []
    @events = Event.joins(:order).group(:order_id).having("max(events.created_at)")
    #logger.debug "**** #{@events.inspect}"

    @events.each do |event|
      if event.event_state_id == @event_order_verified.id
        @order_ids << event.order_id
      end
    end
    #logger.debug "**** ORDER IDS #{@order_ids.inspect}" # , arrival_date: @real_date
    @os = Order.joins(:phones).where(id: @order_ids)
    @phone_ids = Order.joins(:phones).where(id: @order_ids)
    .where('arrival_date == DATE(?)', @real_date).pluck(:phone_id)

    #logger.debug "**** IDS #{@phone_ids.inspect}"
    @phones = Phone.where(id: @phone_ids)
  end

  def current_order
    @today = Date.today
    @orders = self.orders.where(
      "date(arrival_date, '-3 days') <= DATE(?) AND date(departure_date, '+3 days') > DATE(?)", 
      @today, @today)
    
    # TODO: throw warning if more than 1 returned...
    if @orders
      return @orders[0]
    else
      return nil
    end
  end

  def self.check_in(inventory_ids)
    @phones = Phone.where(inventory_id: inventory_ids)

    @delivered_state = EventState.inventoryDelivered

    # TODO: record event only if this phone is currently "out in the field"?
    @estate = EventState.receivedInventory
    @phones.each do |phone|
    #@last_event = Event.lastEventForPhone(phone.id, Date.today)
    #logger.debug "**** LAST EVENT for #{@last_event.inspect}"
    #  if @last_event != nil && 
    #     @last_event.event_state_id == @delivered_state.id
        @event_params = [
          event_state: @estate,
          phone_id: phone.id]
        Event.create(@event_params)
    #    logger.debug "**** CREATED for #{phone.id}"
    #  end
    end
    return @phones
  end

end