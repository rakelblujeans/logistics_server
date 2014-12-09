class Shipment < ActiveRecord::Base
  belongs_to :order
  belongs_to :delivery_type
  has_and_belongs_to_many :phones
end