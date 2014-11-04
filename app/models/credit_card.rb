class CreditCard < ActiveRecord::Base
  belongs_to :customer
  has_many :orderPayments
  #has_many :orders, through :orderPayments
end
