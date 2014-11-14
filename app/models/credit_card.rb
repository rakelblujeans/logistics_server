class CreditCard < ActiveRecord::Base
  belongs_to :customer
  has_many :receipts
end
