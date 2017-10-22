class DinkursEventsController < ApplicationController

  before_action :set_dinkurs_event, only: [:show, :edit, :update, :destroy]

  # TODO before_action :authorize_dinkurs_event, only: []


  # GET /dinkurs_events
  # GET /dinkurs_events.json
  def index
    @dinkurs_events = DinkursEvent.all
  end

  # GET /dinkurs_events/1
  # GET /dinkurs_events/1.json
  def show
  end

  # GET /dinkurs_events/new
  def new
    @dinkurs_event = DinkursEvent.new
  end

  # GET /dinkurs_events/1/edit
  def edit
  end

  # POST /dinkurs_events
  # POST /dinkurs_events.json
  def create
    @dinkurs_event = DinkursEvent.new(dinkurs_event_params)

    respond_to do |format|
      if @dinkurs_event.save
        format.html { redirect_to @dinkurs_event, notice: 'Dinkurs event was successfully created.' }
        format.json { render :show, status: :created, location: @dinkurs_event }
      else
        format.html { render :new }
        format.json { render json: @dinkurs_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dinkurs_events/1
  # PATCH/PUT /dinkurs_events/1.json
  def update
    respond_to do |format|
      if @dinkurs_event.update(dinkurs_event_params)
        format.html { redirect_to @dinkurs_event, notice: 'Dinkurs event was successfully updated.' }
        format.json { render :show, status: :ok, location: @dinkurs_event }
      else
        format.html { render :edit }
        format.json { render json: @dinkurs_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dinkurs_events/1
  # DELETE /dinkurs_events/1.json
  def destroy
    @dinkurs_event.destroy
    respond_to do |format|
      format.html { redirect_to dinkurs_events_url, notice: 'Dinkurs event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dinkurs_event
      @dinkurs_event = DinkursEvent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dinkurs_event_params
      params.fetch(:dinkurs_event, {})
    end
end
