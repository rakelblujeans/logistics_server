class Receipt < ActiveRecord::Base
  belongs_to :order
  belongs_to :credit_card
end
