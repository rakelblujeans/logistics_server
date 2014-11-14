class DeliveryTypesController < ApplicationController
  before_action :set_delivery_type, only: [:show, :edit, :update, :destroy]

  # GET /delivery_types
  # GET /delivery_types.json
  def index
    @delivery_types = DeliveryType.all
  end

  # GET /delivery_types/1
  # GET /delivery_types/1.json
  def show
  end

  # GET /delivery_types/new
  def new
    @delivery_type = DeliveryType.new
  end

  # GET /delivery_types/1/edit
  def edit
  end

  # POST /delivery_types
  # POST /delivery_types.json
  def create
    @delivery_type = DeliveryType.new(delivery_type_params)

    respond_to do |format|
      if @delivery_type.save
        format.html { redirect_to @delivery_type, notice: 'Delivery type was successfully created.' }
        format.json { render :show, status: :created, location: @delivery_type }
      else
        format.html { render :new }
        format.json { render json: @delivery_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /delivery_types/1
  # PATCH/PUT /delivery_types/1.json
  def update
    respond_to do |format|
      if @delivery_type.update(delivery_type_params)
        format.html { redirect_to @delivery_type, notice: 'Delivery type was successfully updated.' }
        format.json { render :show, status: :ok, location: @delivery_type }
      else
        format.html { render :edit }
        format.json { render json: @delivery_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /delivery_types/1
  # DELETE /delivery_types/1.json
  def destroy
    @delivery_type.destroy
    respond_to do |format|
      format.html { redirect_to delivery_types_url, notice: 'Delivery type was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery_type
      @delivery_type = DeliveryType.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def delivery_type_params
      params.require(:delivery_type).permit(:name)
    end
end
