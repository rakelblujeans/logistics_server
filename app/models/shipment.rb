class Shipment < ActiveRecord::Base
  belongs_to :order
  belongs_to :delivery_type
  has_and_belongs_to_many :phones


  def self.addNewHelper(shipment_params)
  	begin
  		@shipment = nil
  		Shipment.transaction do
  			shipment_params[:active] = true
  			
		  	if shipment_params[:hand_delivered_by]
		      @delivery_type = DeliveryType.hand_delivery
		    else
		      # ex:'1Z9999999999999999'
		      @delivery_type = DeliveryType.detect(shipment_params[:delivery_out_code])
		    end
		    shipment_params[:delivery_type_id] = @delivery_type.id


		    # TODO: validate ids
		    @order = Order.find(shipment_params[:order_id])

		    # we may only be shipping a subset of the phones 
		    # included in this order, so take the phone ids from the
		    # parameters passed in.
		    @phones = Phone.where(id: shipment_params[:phone_ids]).all

		    shipment_params[:qty] = @phones.length
		    @shipment = Shipment.new(shipment_params)
		    @shipment.phone_ids = @phones.map(&:id)
		    #logger.debug "***** #{@shipment.phones.inspect}"
		    @shipment.save
		    @estate_delivered = EventState.inventoryDelivered
		    # TODO: pick one and move forward. don't do both
		    Event.create(
		      event_state: @estate_delivered,
		      order_id: @order.id )
		    @phones.each do |phone|
		    	Event.create(
		      event_state: @estate_delivered,
		      phone_id: phone.id )
		    end
		  end
		  @shipment
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

end