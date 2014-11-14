class Phone < ActiveRecord::Base
  belongs_to :provider
  has_many :shipments
  has_many :orders, through: :shipments
end
