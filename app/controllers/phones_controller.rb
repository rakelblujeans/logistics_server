class PhonesController < ApplicationController
  before_action :set_phone, only: [:show, :edit, :update, :destroy, :upcoming_orders]

  # GET /phones
  # GET /phones.json
  def index
    @phones = Phone.all
  end

  # GET /phones/1
  # GET /phones/1.json
  def show
  end

  # GET /phones/new
  def new
    @phone = Phone.new
  end

  # GET /phones/1/edit
  def edit
  end

  # POST /phones
  # POST /phones.json
  def create
    @phone = Phone.new(phone_params)

    respond_to do |format|
      if @phone.save
        # record event
        @estate = EventState.inventoryAdded
        # TODO: catch errors
         @event = Event.create(
          event_state: @estate,
          phone_id: @phone.id)
        format.html { redirect_to @phone, notice: 'Phone was successfully created.' }
        format.json { render :show, status: :created, location: @phone }
      else
        format.html { render :new }
        format.json { render json: @phone.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /phones/1
  # PATCH/PUT /phones/1.json
  def update
    respond_to do |format|
      if @phone.update(phone_params)
        format.html { redirect_to @phone, notice: 'Phone was successfully updated.' }
        format.json { render :show, status: :ok, location: @phone }
      else
        format.html { render :edit }
        format.json { render json: @phone.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /phones/1
  # DELETE /phones/1.json
  def destroy
    @phone.destroy
    respond_to do |format|
      format.html { redirect_to phones_url, notice: 'Phone was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def available_inventory
    #logger.debug("PARAMS #{params.inspect}")
    @phones = Phone.available_inventory(params[:start_date], params[:end_date])
    render "index"
  end

  # GET /phones/1/upcoming_orders.json
  def upcoming_orders
    @orders = @phone.upcoming_orders
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_phone
      @phone = Phone.find(params[:id])
      # @providers = Providers.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def phone_params
      params.require(:phone).permit(:active, :inventory_id, :MEID, :ICCID, :phone_num, 
        :notes, :last_imaged, :provider_id, :start_date, :end_date, :phone_id, :order_id)
    end
end
