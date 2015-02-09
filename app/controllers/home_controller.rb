class HomeController < ApplicationController
  def index
  end

  def search  	
  	# pull phone info
		@phones = Phone.search(params[:q])

  	# pull order info
  	@orders = Order.search(params[:q])
  end

end
