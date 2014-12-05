class Phone < ActiveRecord::Base
  belongs_to :provider
  has_many :shipments
  has_many :orders, through: :shipments

  # all inventory currently assigned to this order
  def self.assignedInventory(id)
    @state = EventState.find_or_create_by(description: "order matched with inventory")
    @events = Event.select(:phone_id).where(
      order_id: id,
      event_state_id: @state.id
      ).order(:created_at)
    
    @used_phone_ids = []
    @events.each do |event|
      @used_phone_ids << event.phone_id
    end

    @phones = Phone.where(id: @used_phone_ids)
  end

  # list of inventory available for assignment during 
  # this data range
  def self.availableInventory(in_start, in_end)
    # sanity check
    if !in_start || !in_end
      return []
    end

    #logger.debug("#{in_start}, #{in_end}")
    # TODO: add padding for lead times
    @lead_time = 0
    @start_date = in_start
    @end_date = in_end

    #@events = Event.select(:phone_id).joins(:order).where('arrival_date < DATE(?)', '2014-12-10');
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

  # gets a complete picture of what inventory looks like
  # relative to this order: what has already been assigned,
  # and what you have left to choose from
  def self.inventorySnapshot(id)
    @order = Order.where(id: id).first!;
    logger.debug "#{@order.inspect}"
    @assigned = assignedInventory(id);
    @available = availableInventory(@order.arrival_date, @order.departure_date);
    return @assigned, @available
  rescue ActiveRecord::RecordNotFound
      @assigned = []
      @available = []
  end
end
