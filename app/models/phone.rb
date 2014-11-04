class Phone < ActiveRecord::Base
  has_many :orders
  belongs_to :provider
end
