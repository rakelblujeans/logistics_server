class Shipment < ActiveRecord::Base
  belongs_to :order
  belongs_to :delivery_type
  has_and_belongs_to_many :phones


  def self.addNewHelper(shipment_params)
  	begin
  		@shipment = nil
  		Shipment.transaction do
		  	if shipment_params["hand_delivered_by"]
		      @delivery_type = DeliveryType.hand_delivery
		    else
		      # ex:'1Z9999999999999999'
		      @delivery_type = DeliveryType.detect(shipment_params["delivery_out_code"])
		    end
		    shipment_params["delivery_type_id"] = @delivery_type.id

		    # TODO: validate ids
		    @phone_ids = shipment_params["phone_ids"]
		    @phones = Phone.where(id: @phone_ids).all
		    shipment_params["qty"] = @phones.length
		    @shipment = Shipment.new(shipment_params)
		    @shipment.phone_ids = @phones.map(&:id)
		    @shipment.save
		    @estate_delivered = EventState.inventoryDelivered
		    @event = Event.create(
		      event_state: @estate_delivered,
		      order_id: shipment_params["order_id"])
		    # TODO: why not record phone_id here?
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