class Customer < ActiveRecord::Base
	has_many :credit_cards
	has_many :orders
	has_many :shipments
	has_many :events
end
