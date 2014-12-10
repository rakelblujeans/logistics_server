class Phone < ActiveRecord::Base
  belongs_to :provider
  has_and_belongs_to_many :shipments
  has_and_belongs_to_many :orders

  def self.date?(obj)
    obj.kind_of?(Date)
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

    logger.debug @upcoming_orders
    return @upcoming_orders
  end

end