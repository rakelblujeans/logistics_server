class EventStatesController < ApplicationController
  before_action :set_event_state, only: [:show, :edit, :update, :destroy]

  # GET /event_states
  # GET /event_states.json
  def index
    @event_states = EventState.all
  end

  # GET /event_states/1
  # GET /event_states/1.json
  def show
  end

  # GET /event_states/new
  def new
    @event_state = EventState.new
  end

  # GET /event_states/1/edit
  def edit
  end

  # POST /event_states
  # POST /event_states.json
  def create
    @event_state = EventState.new(event_state_params)

    respond_to do |format|
      if @event_state.save
        format.html { redirect_to @event_state, notice: 'Event state was successfully created.' }
        format.json { render :show, status: :created, location: @event_state }
      else
        format.html { render :new }
        format.json { render json: @event_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /event_states/1
  # PATCH/PUT /event_states/1.json
  def update
    respond_to do |format|
      if @event_state.update(event_state_params)
        format.html { redirect_to @event_state, notice: 'Event state was successfully updated.' }
        format.json { render :show, status: :ok, location: @event_state }
      else
        format.html { render :edit }
        format.json { render json: @event_state.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_states/1
  # DELETE /event_states/1.json
  def destroy
    @event_state.destroy
    respond_to do |format|
      format.html { redirect_to event_states_url, notice: 'Event state was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event_state
      @event_state = EventState.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_state_params
      params.require(:event_state).permit(:description)
    end
end
