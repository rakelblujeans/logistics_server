class DeliveryType < ActiveRecord::Base
	has_many :shipments

	def self.fedex
  	return _get_or_create_type("Fedex")
  end

  def self.usps
  	return _get_or_create_type("USPS")
  end

  def self.ups
  	return _get_or_create_type("UPS")
  end

  def self.hand_delivery
  	return _get_or_create_type("Hand delivery")
  end

  def self.other
  	return _get_or_create_type("Unknown method")
  end

  def self.detect(input)
  	# Fedex
    @rFedex1 = /\b\d{12}\b/
    @rFedex2 = /\b96\d{20}\b/
    @rFedex3 = /\b\d{15}\b/
    @rFedex4 = /\b((98\d{5}?\d{3}|98\d{2}) ?\d{4} ?\d{4}( ?\d{2})?)\b/
    # USPS
		@rUSPS1 = /^E\D{1}\d{9}\D{2}$|^9\d{15,21}$/i
		# UPS
		@rUPS1 = /^.Z/i
		@rUPS2 = /^[HK].{10}$/i

    case input
    when @rFedex1
    	return DeliveryType.fedex
    when @rFedex2
    	return DeliveryType.fedex
    when @rFedex3
    	return DeliveryType.fedex
    when @rFedex4
    	return DeliveryType.fedex
    when @rUSPS1
    	return DeliveryType.usps
    when @rUPS1
    	return DeliveryType.ups
    when @rUPS2
    	return DeliveryType.ups
    else
     return DeliveryType.other
    end
  end

	private
	  def self._get_or_create_type(name)
	  		@dtype = DeliveryType.where(name: name).first!
	  	return @dtype
	  rescue ActiveRecord::RecordNotFound
	  	@dtype = DeliveryType.new(name: name)
	  end
end