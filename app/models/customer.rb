class Customer < ActiveRecord::Base
	has_many :credit_cards
	has_many :orders
end
