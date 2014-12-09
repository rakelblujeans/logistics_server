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
    params[:active] = true
    params[:arrival_date].sub! "/", "-"
    params[:departure_date].sub! "/", "-"
    @order = Order.new(order_params)

    @state = EventState.orderReceived
    @event = Event.create(
      event_state: @estate,
      order_id: @order.id)

    respond_to do |format|
      if @order.save

        # assign phones
        # TODO: dumb assignment for now, needs optimization
        @order.bruteForceAssignPhones

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
        
        @order.bruteForceAssignPhones

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

  # POST orders/assignDevice
  def assignDevice
    # TODO: wrap in transaction...
    @order = Order.where(id: params[:order_id]).first!
    @phone = Phone.where(id: params[:phone_id]).first!
    @order.phones << @phone

    @state = EventState.matchedInventory
    Event.create(
      event_state_id: @state.id,
      phone_id: @phone.id,
      order_id: @order.id)

  rescue ActiveRecord::RecordNotFound
    # TODO: log internally. don't show client facing message.
  ensure
    respond_to do |format|
      #if @order.save
        format.html { redirect_to @order, notice: 'Device was successfully assigned.' }
        format.json { render :show, status: :ok, location: @order }
      #else
      #  format.html { render :new }
      #  format.json { render json: @order.errors, status: :unprocessable_entity }
      #end
    end
  end

  # DELETE orders/removeMatched.json
  def unassignDevice
    # TODO: wrap in transaction...
    
    # update order's phone list
    @order = Order.where(id: params[:order_id]).first!
    @order.phones.each do |phone|
      if phone.id == params[:phone_id].to_i
        @order.phones.delete(phone)
        break
      end
    end

    # update recorded events
    @state = EventState.matchedInventory
    @event = Event.where(
      order_id: params[:order_id],
      phone_id: params[:phone_id],
      event_state_id: @state.id).first!
    if @event != nil
      @event.destroy
    end

  rescue ActiveRecord::RecordNotFound
    # TODO: log internally. don't show client facing message.
  ensure
    respond_to do |format|
      format.html { redirect_to @order, notice: 'Device removed from order' }
      format.json { render :show, status: :ok, location: @order }
    end
  end

  # POST /orders/markVerified.json
  def markVerified
    # TODO: error checking
    @order = Order.where(id: params[:order_id]).first!

    # update recorded events
    @state = EventState.orderVerified
    @event = Event.create(
      order_id: params[:order_id],
      event_state_id: @state.id)
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
