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
      if order.arrival_date < today
        @upcoming_orders << order
      end
    end

    return @upcoming_orders
  end

  # what phones arrive in our office on this date?
  def self.incoming_on(in_date)
    # if string, convert to date object
    in_date.sub! "/", "-"
    if self.string? in_date
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
    # TODO: if you want to track delivery events, replace the line above
    # with some like this:
=begin
    @state_received = EventState.receivedInventory
    @order_ids = []
    @events = Event.joins(:order).group(:order_id).having(
      "max(events.created_at) AND departure_date == " + @departure_date)
    @events.each do |event|
      if event.event_state_id == @state_received.id || 
        event.event_state_id == @state_matched.id
        @order_ids << event.order_id
      end
    end
=end
    @phones = Phone.where(id: @phone_ids)
  end

end