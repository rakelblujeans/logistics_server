class OrderPaymentsController < ApplicationController
  before_action :set_order_payment, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, :only => [:update]

  # GET /order_payments
  # GET /order_payments.json
  def index
    @order_payments = OrderPayment.all
  end

  # GET /order_payments/1
  # GET /order_payments/1.json
  def show
  end

  # GET /order_payments/new
  def new
    @order_payment = OrderPayment.new
  end

  # GET /order_payments/1/edit
  def edit
  end

  # POST /order_payments
  # POST /order_payments.json
  def create
    @order_payment = OrderPayment.new(order_payment_params)

    respond_to do |format|
      if @order_payment.save
        format.html { redirect_to @order_payment, notice: 'Order payment was successfully created.' }
        format.json { render :show, status: :created, location: @order_payment }
      else
        format.html { render :new }
        format.json { render json: @order_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /order_payments/1
  # PATCH/PUT /order_payments/1.json
  def update
    respond_to do |format|
      if @order_payment.update(order_payment_params)
        format.html { redirect_to @order_payment, notice: 'Order payment was successfully updated.' }
        format.json { render :show, status: :ok, location: @order_payment }
      else
        format.html { render :edit }
        format.json { render json: @order_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /order_payments/1
  # DELETE /order_payments/1.json
  def destroy
    @order_payment.destroy
    respond_to do |format|
      format.html { redirect_to order_payments_url, notice: 'Order payment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_payment
      @order_payment = OrderPayment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_payment_params
      params.require(:order_payment).permit(:bt_trans_id, :discount_code, :shipping_string, :referral_code, :rental_charge, :shipping_charge, :rental_discount, :tax_charge, :payment_amount, :payment_date, :payment_status, :discount_string, :last_4_digits, :refunded, :order_id, :credit_card_id)
    end
end
