class Order < ActiveRecord::Base
  belongs_to :customer
  belongs_to :phone
  has_one :order_payment
end