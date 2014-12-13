ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def create_phone(phone_fixture)
		# create a phone using our addNew()
  	@params = phone_fixture.attributes
		@params.delete("id")
  	@phone = Phone.addNew(@params)
  	@phone
  end

  def create_order(order_fixture)
  	@params = order_fixture.attributes
		@params.delete("id")
  	@order = Order.addNew(@params)
  end

  def create_shipment(shipment_fixture, order, phone)
		# create a shipment using our addNew()
  	@params = shipment_fixture.attributes
		@params.delete("id")
		@params["order_id"] = order.id
		@params["phone_ids"] = [phone.id]
  	@ship = Shipment.addNew(@params)
  	@ship
  end
end
