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

    # convert date objects into strings
    in_start = in_start.strftime("%Y-%m-%d")
    in_end = in_end.strftime("%Y-%m-%d")

    @orders = Order.where(active: true)        
    @used_phone_ids = @orders.joins(:phones).where("departure_date >= DATE(?) AND departure_date < DATE(?)", in_start, in_end).pluck(:phone_id)

    # return the complement of that set
    #puts "\nCURRENTLY USED PHONES: #{@used_phone_ids.inspect} BETWEEN #{in_start} #{in_end}"
    @phones = Phone.where(active: true);
    #puts "\nACTIVE: #{@phones.ids.inspect}"
    @phones = @phones.where.not(id:@used_phone_ids).order(:inventory_id)
    #puts "FOUND AVAILABLE: #{@phones.ids.inspect}"
    @phones
  end

  def self.check_in(inventory_ids)
    @phones = Phone.where(inventory_id: inventory_ids)
    @estate = EventState.received_inventory

    @phones.each do |phone|
      @event_params = {
        event_state_id: @estate.id,
        phone_id: phone.id}
      @event = Event.create(@event_params)

      # if all phones for this order have been checked in
      # mark order complete
      if phone.last_order && 
        phone.last_order.phones_still_out.length == 0
        phone.last_order.mark_complete
      end
    end

    @phones
  end

  def past_orders
    @past_orders = self.orders.where("date(departure_date, '+3 days') < DATE(?)", Date.today)
    @past_orders
  end

  def last_order
    @last_order = self.orders
      .where("date(departure_date, '+3 days') < DATE(?)", Date.today)
      .order(created_at: :desc)
      .first
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
    @state_canceled = EventState.deactivated
    Event.create(
      event_state_id: @state_canceled.id,
      phone_id: self.id)

    self.update(active: false);

    #logger.debug "\n\n UPCOMING ORDERS\n#{self.upcoming_orders.inspect}"
    self.upcoming_orders.each do |order|
      if order.unassign_device(self.id)
        order.brute_force_assign_phones
      end
    end
  end

end