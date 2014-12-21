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
    #params[:arrival_date].gsub! "/", "-"
    #params[:departure_date].gsub! "/", "-"
    @order = Order.addNew(order_params)
    @order.brute_force_assign_phones
=begin
    respond_to do |format|
      if @order
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
=end
    if @order
      respond_with @order, :status => :created, :location => @order
    else
      respond_with @order, :status => :unprocessable_entity
    end
  end

  # PATCH/PUT /orders/1.json
  def update
=begin
    respond_to do |format|
      if @order.update(order_params)
        
        @order.brute_force_assign_phones

        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
=end
  if @order.update(order_params)
      respond_with @order, :status => :ok, :location => @order
    else 
      respond_with @order, :status => :unprocessable_entity
    end
  end

  # DELETE /orders/1.json
  def destroy
    @order.destroy
    #respond_to do |format|
    #  format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
    #  format.json { head :no_content }
    #end
    respond_with :head => :no_content
  end

  # GET /orders/unmatched
  def unverified
    @orders = Order.unverified
    #respond_with @orders
    render 'index'
  end

  # POST /orders/mark_verified.json
  def mark_verified
    # TODO: error checking
    @order.mark_verified
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
