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

        @estate = EventState.inventory_added
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
  # expects dates as YYYY-MM-DD
  def self.available_inventory(in_start, in_end)
    # sanity check
    if !in_start || !in_end
      return []
    end

    if self.string? in_start
      in_start.gsub! "/", "-"
      in_start = Date.strptime(in_start, "%Y-%m-%d")
    end
    
    if self.string? in_end
      in_end.gsub! "/", "-"
      in_end = Date.strptime(in_end, "%Y-%m-%d")
    end

    # add padding for lead times
    @lead_time = 3
    @start_date = in_start - @lead_time
    @end_date = in_end + @lead_time

    # convert date objects into strings
    in_start = in_start.strftime("%Y-%m-%d")
    in_end = in_end.strftime("%Y-%m-%d")
    
    #puts "checking available btwn #{in_start} #{in_end}"
    #.where("(DATE(?) <= arrival_date AND arrival_date < DATE(?)) OR (DATE(?) <= departure_date AND departure_date < DATE(?))", 

    @events = Event.joins(:order).group(:phone_id)
    .where("departure_date >= DATE(?) AND departure_date < DATE(?)", in_start, in_end)
    .having("max(events.created_at)")
    #puts "\n**FOUND** #{@events.inspect} #{in_start}"
    @used_phone_ids = []
    @state_matched = EventState.matched_inventory

    #puts "#{@events.inspect}"
    @events.each do |event|
      if event.event_state_id == @state_matched.id #&&
        #event.order.departure_date > @start_date
        @used_phone_ids << event.phone_id
      end
    end

    # return the complement of that set
    #puts "\nCURRENTLY USED PHONES: #{@used_phone_ids.inspect} BETWEEN #{@start_date} #{@end_date} "
    @phones = Phone.where(active: true);
    #puts "\nACTIVE: #{@phones.ids.inspect}"
    @phones = @phones.where.not(id:@used_phone_ids).order(:inventory_id)
    #puts "FOUND: #{@phones.ids.inspect}"
    @phones
  end

  def self.check_in(inventory_ids)
    @phones = Phone.where(inventory_id: inventory_ids)
    @estate = EventState.received_inventory

    @phones.each do |phone|
      @event_params = {
        event_state_id: @estate.id,
        phone_id: phone.id}
      #if phone.current_order
      #  @event_params[:order_id] = phone.current_order.id
      #end
      @event = Event.create(@event_params)
    end

    # if all phones for this order have been checked in, mark order complete
    # TODO?
    return @phones
  end

  def past_orders
    @past_orders = self.orders.where("date(departure_date, '+3 days') < DATE(?)", Date.today)
    @past_orders
  end

  def last_order
    @last_order = self.orders
      .where("date(departure_date, '+3 days') < DATE(?)", Date.today)
      .order(created_at: :desc)
      .first!
    @last_order
  end

  def upcoming_orders
    @upcoming_orders = self.orders.where("date(arrival_date, '-3 days') >= DATE(?)", Date.today)
    @upcoming_orders
  end

  def current_order
    @today = Date.today
    @order = self.orders.where(
      "date(arrival_date, '-3 days') <= DATE(?) AND date(departure_date, '+3 days') > DATE(?)", 
      @today, @today).first!
    @order
  rescue ActiveRecord::RecordNotFound
    return nil
  end

  def deactivate
    self.update(active: false);

    self.upcoming_orders.each do |order|
      if order.unassign_device(self.id)
        order.brute_force_assign_phones
      end
    end
  end

end