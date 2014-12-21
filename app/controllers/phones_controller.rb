class PhonesController < ApplicationController
  before_action :set_phone, only: [:show, :edit, :update, :destroy, :upcoming_orders]
  
  # GET /phones.json
  def index
    @phones = Phone.all
  end

  # GET /phones/1.json
  def show
  end

  # GET /phones/new.json
  def new
    @phone = Phone.new
    respond_with @phone
  end

  # GET /phones/1/edit.json
  def edit
    respond_with @phone
  end

  # POST /phones.json
  def create
    @phone = Phone.addNew(phone_params)
    if @phone
      respond_with @phone, :status => :created, :location => @phone
    else
      respond_with @phone, :status => :unprocessable_entity
    end
  end

  # PATCH/PUT /phones/1.json
  def update
    if @phone.update(phone_params)
      respond_with @phone, :status => :ok, :location => @phone
    else 
      respond_with @phone, :status => :unprocessable_entity
    end
  end

  # DELETE /phones/destroy/1.json
  def destroy
    @phone.destroy
    respond_with :head => :no_content
  end
  
  # GET /phone/available_inventory.json
  def available_inventory
    logger.debug("PARAMS #{params.inspect}")
    @phones = Phone.available_inventory(params[:start_date], params[:end_date])
    render 'index'
  end

  # GET /phones/1/upcoming_orders.json
  def upcoming_orders
    @orders = @phone.upcoming_orders
    render 'orders/index'
  end

  # GET /phones/1/current_order.json
  def current_order
    @phone = Phone.find(params[:id])
    @orders = @phone.current_order
    render 'orders/index'    
  end

  # GET /phones/incoming_on.json
  def incoming_on
    @phones = Phone.incoming_on(params[:date])
    render 'index'
  end

  # POST /phones/check_in/1.json
  def check_in
    @phones = Phone.check_in(params[:inventory_ids])
    respond_with @phones, :status => :ok, :location => phones_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phone
      @phone = Phone.where(inventory_id: params[:id]).first!
    rescue ActiveRecord::RecordNotFound
      @phone = Phone.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def phone_params
      params.require(:phone).permit(:active, :inventory_id, :inventory_ids, :MEID, :ICCID, :phone_num, 
        :notes, :last_imaged, :provider_id, :start_date, :end_date, :phone_id, :order_id)
    end
end
