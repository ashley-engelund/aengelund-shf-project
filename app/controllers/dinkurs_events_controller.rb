class DinkursEventsController < ApplicationController

  before_action :set_dinkurs_event, only: [:show, :edit, :update, :destroy]
  before_action :authorize_dinkurs_event, only: [:show, :edit, :update, :destroy]
  before_action :authorize_dinkurs_class, only: [:index, :new, :create, :get_dinkurs_events]


  def index
    @dinkurs_events = DinkursEvent.all
  end


  def show
  end


  def new
    @dinkurs_event = DinkursEvent.new
  end


  def edit
  end


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


  def authorize_dinkurs_event
    authorize @dinkurs_event
  end


  def authorize_dinkurs_class
    authorize DinkursEvent
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def dinkurs_event_params
    params.require(:dinkurs_event).permit(:event_name,
                                          :dinkurs_id,
                                          :event_place,
                                          :event_place_geometry,
                                          :event_host,
                                          :event_fee,
                                          :event_fee_tax,
                                          :event_pub,
                                          :event_apply,
                                          :event_start,
                                          :event_stop,
                                          :event_key,
                                          :event_participant_number,
                                          :event_participant_reserve,
                                          :event_participants,
                                          :event_occasions,
                                          :event_group,
                                          :event_position,
                                          :event_instructor_1,
                                          :event_instructor_2,
                                          :event_instructor_3,
                                          :event_infotext,
                                          :event_commenttext,
                                          :event_ticket_info,
                                          :event_url_id,
                                          :event_url_key,
                                          :event_completion_text,
                                          :event_aftertext,
                                          :event_event_dates,
                                          :company_id)
  end

end
