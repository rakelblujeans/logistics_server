class ShipmentsController < ApplicationController
  before_action :set_shipment, only: [:show, :edit, :update, :destroy]

  # GET /shipments
  # GET /shipments.json
  def index
    @shipments = Shipment.all
  end

  # GET /shipments/1
  # GET /shipments/1.json
  def show
  end

  # GET /shipments/new
  def new
    @shipment = Shipment.new
  end

  # GET /shipments/1/edit
  def edit
  end

  # POST /shipments
  # POST /shipments.json
  def create
    # TODO transaction wrap Shipment.transaction do
    #TODO: dynamically determine delivery type by analyzing code
    #@delivery_type = DeliveryType.fedex
    #params[:shipment][:delivery_type_id] = @delivery_type.id

    if params[:shipment][:hand_delivered_by]
      @delivery_type = DeliveryType.hand_delivery
    else
      # ex:'1Z9999999999999999'
      @delivery_type = DeliveryType.detect(params[:shipment][:delivery_out_code])
    end
    params[:shipment][:delivery_type_id] = @delivery_type.id

    # TODO: validate ids
    @phone_ids = shipment_params[:phone_ids]
    @phones = Phone.where(id: @phone_ids).all
    params[:shipment][:qty] = @phones.length
    @shipment = Shipment.new(shipment_params)
    @shipment.phone_ids = @phones.map(&:id)

    @estate = EventState.inventoryDelivered
    @event = Event.create(
      event_state: @estate,
      order_id: shipment_params[:order_id])

    respond_to do |format|
      if @shipment.save
        format.html { redirect_to @shipment, notice: 'Shipment was successfully created.' }
        format.json { render :show, status: :created, location: @shipment }
      else
        format.html { render :new }
        format.json { render json: @shipment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shipments/1
  # PATCH/PUT /shipments/1.json
  def update
    respond_to do |format|
      if @shipment.update(shipment_params)
        format.html { redirect_to @shipment, notice: 'Shipment was successfully updated.' }
        format.json { render :show, status: :ok, location: @shipment }
      else
        format.html { render :edit }
        format.json { render json: @shipment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shipments/1
  # DELETE /shipments/1.json
  def destroy
    @shipment.destroy
    respond_to do |format|
      format.html { redirect_to shipments_url, notice: 'Shipment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shipment
      @shipment = Shipment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shipment_params
      #params[:shipment][:phone_ids] ||= []
      params.require(:shipment).permit(:active, :delivery_out_code, 
        :delivery_return_code, :hand_delivered_by, :delivery_type_id, 
        :qty, :out_on_date, :order_id, phone_ids: [])
    end
end
