class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/unmatched
  def unverified
    @orders = Order.unverified
  end

  def verified
    @orders = Order.verified
    respond_to do |format|
      #format.html { render @order, notice: 'Order was successfully created.' }
      format.json { render :index, status: :ok, location: @order }
    end
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    params[:arrival_date].sub! "/", "-"
    params[:departure_date].sub! "/", "-"
    @order = Order.addNew(order_params)
    respond_to do |format|
      if @order
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
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
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST orders/assign_device
  def assign_device
    @order = Order.where(id: params[:order_id]).first!
    @order.assign_device(params[:phone_id])
  rescue ActiveRecord::RecordNotFound
    # TODO: log internally. don't show client facing message.
  ensure
    respond_to do |format|
        format.html { redirect_to @order, notice: 'Device was successfully assigned.' }
        format.json { render :show, status: :ok, location: @order }
      #else
      #  format.html { render :new }
      #  format.json { render json: @order.errors, status: :unprocessable_entity }
      #end
    end
  end

  # DELETE orders/unassign_device.json
  def unassign_device
    @order = Order.where(id: params[:order_id]).first!
    @order.unassign_device(params[:phone_id])
  rescue ActiveRecord::RecordNotFound
    # TODO: log internally. don't show client facing message.
  ensure
    respond_to do |format|
      format.html { redirect_to @order, notice: 'Device removed from order' }
      format.json { render :show, status: :ok, location: @order }
    end
  end

  # POST /orders/mark_verified.json
  def mark_verified
    # TODO: error checking
    @order = Order.where(id: params[:order_id]).first!
    @order.mark_verified
  rescue ActiveRecord::RecordNotFound
  ensure
    respond_to do |format|
      format.html { redirect_to @order, notice: 'Order successfully verified' }
      format.json { render :show, status: :ok, location: @order }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:invoice_id, :active, :delivery_type_str, 
        :full_address, :shipping_name, :shipping_city, :shipping_state, 
        :shipping_zip, :shipping_country, :shipping_apt_suite, :shipping_notes, 
        :arrival_date, :departure_date, :language, :num_phones)
    end
end
