class EventState < ActiveRecord::Base
  has_many :events 

  def self.inventoryAdded
  	return _get_or_create_state("inventory added")
  end

	def self.orderReceived
  	return _get_or_create_state("order received")
	end

  def self.matchedInventory
  	return _get_or_create_state("order matched with inventory")
	end

	def self.orderVerified # marks it ready for delivery
  	return _get_or_create_state("order assignment verified")
	end

	def self.outForDelivery
		return _get_or_create_state("out for delivery")
	end

  private
	  def self._get_or_create_state(description)
	  		@state = EventState.where(description: description).first!
	  	return @state
	  rescue ActiveRecord::RecordNotFound
	  	@state = EventState.new(description: description)
	  end
end