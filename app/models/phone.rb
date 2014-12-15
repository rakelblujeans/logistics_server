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

    # convert date objects into strings
    if self.date? in_start
      in_start = in_start.strftime("%Y-%m-%d")
    end

    if self.date? in_end
      in_end = in_end.strftime("%Y-%m-%d")
    end

    # clean up strings
    in_start.sub! "/", "-"
    in_end.sub! "/", "-"

    # TODO: add padding for lead times
    @lead_time = 0
    @start_date = in_start
    @end_date = in_end

    @events = Event.select(:phone_id).joins(:order).where("(DATE(?) <= arrival_date AND arrival_date < DATE(?)) OR (DATE(?) <= departure_date AND departure_date < DATE(?))", 
      @start_date, @end_date, @start_date, @end_date)
    # find the set of phones they're using
    @used_phone_ids = []
    @events.each do |event|
      @used_phone_ids << event.phone_id
    end
    # return the complement of that set
    @phones = Phone.where.not(id:@used_phone_ids).order(:inventory_id)
  end

  def upcoming_orders
    @upcoming_orders = []

    today = Time.now.utc
    self.orders.each do |order|
      if order.arrival_date > today
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
    @events.each do |event|
      if event.event_state_id == @state_inventory_sent.id
        @order_ids << event.order_id
      end
    end

    @phone_ids = Order.joins(:phones).where(id: @order_ids, departure_date: @departure_date).pluck(:phone_id)
    @phones = Phone.where(id: @phone_ids)
  end

  # what phones leave our office on this date?
  def self.outbound_on(in_date)
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
    @real_date = @real_date.strftime("%Y-%m-%d")

    # only consider orders that we have manually verified
    # as "shippable"
    @event_order_verified = EventState.orderVerified
    @order_ids = []
    @events = Event.joins(:order).group(:order_id).having("max(events.created_at)")

    @events.each do |event|
      if event.event_state_id == @event_order_verified.id
        @order_ids << event.order_id
      end
    end

    @phone_ids = Order.joins(:phones).where(id: @order_ids, arrival_date: @real_date).pluck(:phone_id)
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

  def self.check_in(id)
    @phone = Phone.find(id)

    # record event
    @estate = EventState.receivedInventory
    @event_params = [
      event_state: @estate,
      phone_id: @phone.id]
    @event = Event.create(@event_params)

    return @phone
  end

end