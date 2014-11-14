class DeliveryType < ActiveRecord::Base
	has_many :shipments
end