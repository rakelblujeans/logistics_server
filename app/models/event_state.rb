class EventState < ActiveRecord::Base
  has_many :events 

  def self.inventory_added
  	return _get_or_create_state("inventory added")
  end

	def self.order_received
  	return _get_or_create_state("order received")
	end

  def self.matched_inventory
  	return _get_or_create_state("order matched with inventory")
	end

	def self.unassigned_inventory
  	return _get_or_create_state("order unmatched with inventory")
	end

	def self.order_verified # marks it ready for delivery
  	return _get_or_create_state("order assignment verified")
	end

	def self.order_unverified # marks it ready for delivery
  	return _get_or_create_state("order assignment unverified")
	end

	def self.inventory_delivered
		return _get_or_create_state("out for delivery")
	end

# NOTE: these can be tracked once we integrate a delivery API
#	def self.customerReceived
#		return _get_or_create_state("received by customer")
#	end

#	def self.customerSentBack
#		return _get_or_create_state("sent out by customer")
#	end

	def self.received_inventory
		return _get_or_create_state("inventory received by office")
	end

	def self.order_completed
		return _get_or_create_state("order completed")
	end

	def self.deactivated
		return _get_or_create_state("deactivated")
	end

  private
	  def self._get_or_create_state(description)
	  		@state = EventState.where(description: description).first!
	  	return @state
	  rescue ActiveRecord::RecordNotFound
	  	@state = EventState.create(description: description)
	  end
end