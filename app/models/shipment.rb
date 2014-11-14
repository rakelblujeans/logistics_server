class Shipment < ActiveRecord::Base
  belongs_to :order
  belongs_to :delivery_type
  belongs_to :customer
  has_many :phones
end