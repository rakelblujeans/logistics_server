class Order < ActiveRecord::Base
  belongs_to :customer
  has_many :shipments
  has_many :phones, through: :shipments
  has_many :receipts
  has_many :event_logs
end