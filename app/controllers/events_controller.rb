class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  def createMatched
    @state = EventState.matchedInventory
    params[:event][:event_state_id] = @state.id
    _create
  end

  def removeMatched
    @state = EventState.matchedInventory
    #logger.debug "******* {#{params.inspect}}"
    #@event = Event.where(event_params).first
    @event = Event.where(
      order_id: params[:order_id],
      phone_id: params[:phone_id],
      event_state_id: @state.id).first!
    _destroy
  rescue ActiveRecord::RecordNotFound
    #ignore
  end

  # POST /events
  # POST /events.json
  def create
    _create
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    _delete
    #@event.destroy
    #respond_to do |format|
    #  format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
    #  format.json { head :no_content }
    #end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    def _destroy
      @event.destroy
      respond_to do |format|
        format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    def _create
      #logger.debug("PARAMSSS #{params.inspect}")
      @event = Event.new(event_params)
      respond_to do |format|
        if @event.save
          format.html { redirect_to @event, notice: 'Event was successfully created.' }
          format.json { render :show, status: :created, location: @event }
        else
          format.html { render :new }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      #logger.debug("PARAMSSS #{params.inspect}")
      params.require(:event).permit(:id, :created_at, :upated_at, 
        :customer_id, :order_id, :phone_id, :event_state_id)
    end
end
