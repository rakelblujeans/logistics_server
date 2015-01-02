class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy, :mark_verified, :assign_device, :unassign_device]

  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
    respond_with @order
  end

  # GET /orders/1/edit
  def edit
    respond_with @order
  end

  # POST /orders.json
  def create
    @order = Order.addNew(order_params)
    @order.brute_force_assign_phones

    if @order
      respond_with @order, :status => :created, :location => @order
    else
      respond_with @order, :status => :unprocessable_entity
    end
  end

  # PATCH/PUT /orders/1.json
  def update
    if @order.update_data(order_params)
      respond_with @order, :status => :ok, :location => @order
    else 
      respond_with @order, :status => :unprocessable_entity
    end
  end

  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_with :head => :no_content
  end

  # GET /orders/unmatched
  def unverified
    @orders = Order.unverified
    render 'index'
  end

  # POST /orders/mark_verified.json
  def mark_verified
    @order.mark_verified(params[:is_verified])
    @order    
  rescue ActiveRecord::RecordNotFound
    # TODO
  ensure
    render 'show'
  end

  def verified
    @orders = Order.verified
    render 'index'
  end

  # POST orders/assign_device
  def assign_device
    @order.assign_device(params[:phone_id])
    @order
  rescue ActiveRecord::RecordNotFound
    # TODO: log internally. don't show client facing message.
  ensure
    render 'show'
  end

  # DELETE orders/unassign_device.json
  def unassign_device
    @order.unassign_device(params[:phone_id])
    @order
  rescue ActiveRecord::RecordNotFound
    # TODO: log internally. don't show client facing message.
  ensure
    render 'show'
  end

  # GET /orders/outbound_on.json
  def outbound_on
    @data = Order.outbound_on(params[:date])
  end

  # GET /orders/incoming_on.json
  def incoming_on
    @data = Order.incoming_on(params[:date])
  end

  # GET /orders/currently_out.json
  def currently_out
    @orders = Order.currently_out
    render 'index'
  end

  # POST /orders/mark_complete.json
  def mark_complete
    @order = Order.mark_complete(params[:invoice_id])
    render 'show'
  end

  def overdue
    @orders = Order.overdue
    render 'index'
  end

  def overdue_shipping
    @orders = Order.overdue_shipping
    render 'index'
  end

  def missing_phones
    @orders = Order.missing_phones
    render 'index'
  end

  #def warnings
  #  [@overdue, @shipping, @missing_phones] = Order.warnings
  #end

  # POST /orders/1/toggle_activation.json
  def toggle_activation
    @order = Order.find(params[:id])
    if @order
      if @order.active
        @order.cancel
      else
        @order.update_data({active: true})
      end

      respond_with @order, :status => :ok, :location => @order
    else
      respond_with @order, :status => :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.where(id: params[:id]).first!
    rescue ActiveRecord::RecordNotFound
      @order = Order.where(invoice_id: params[:id]).first!
    ensure
      if @order
        @is_verified = @order.is_verified
      else
        @is_verified = false
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:invoice_id, :active, :delivery_type_str, 
        :full_address, :shipping_name, :shipping_city, :shipping_state, 
        :shipping_zip, :shipping_country, :shipping_apt_suite, :shipping_notes, 
        :arrival_date, :departure_date, :language, :num_phones)
    end
end
