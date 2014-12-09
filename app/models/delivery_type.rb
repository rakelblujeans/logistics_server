class DeliveryType < ActiveRecord::Base
	has_many :shipments

	def self.fedex
  	return _get_or_create_type("Fedex")
  end

  def self.ups
  	return _get_or_create_type("UPS")
  end

  def self.hand_delivery
  	return _get_or_create_type("Hand delivery")
  end

	private
	  def self._get_or_create_type(name)
	  		@dtype = DeliveryType.where(name: name).first!
	  	return @dtype
	  rescue ActiveRecord::RecordNotFound
	  	@dtype = DeliveryType.new(name: name)
	  end
end