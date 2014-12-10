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

	def self.inventoryDelivered
		return _get_or_create_state("inventory delivered")
	end

	def self.customerReceived
		return _get_or_create_state("received by customer")
	end

	def self.customerSentBack
		return _get_or_create_state("sent out by customer")
	end

	def self.receivedInventory
		return _get_or_create_state("inventory received by office")
	end

  private
	  def self._get_or_create_state(description)
	  		@state = EventState.where(description: description).first!
	  	return @state
	  rescue ActiveRecord::RecordNotFound
	  	@state = EventState.create(description: description)
	  end
end