class EventState < ActiveRecord::Base
  has_many :events 

  def self.inventoryAdded
  	return _get_or_create_state("inventory added")
  end

  def self.matchedInventory
  	return _get_or_create_state("order matched with inventory")
	end

  private
	  def self._get_or_create_state(description)
	  		@state = EventState.where(description: description).first!
	  	return @state
	  rescue ActiveRecord::RecordNotFound
	  	@state = EventState.new(description: description)
	  end
end