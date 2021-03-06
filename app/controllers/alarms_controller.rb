class AlarmsController < ApplicationController

  helper_method :alarms, :sort_column, :sort_direction
  before_action :set_alarm, only: [:show, :edit, :update, :destroy, :run]

  def index
  end

  def show
  end

  def new
    @alarm = Alarm.new(action: 'logger')
  end

  def edit
  end

  def run
    event = ExpectedEvent.new(
      title: 'Tested using a bogus event expectation',
      matching_direction: 'backward',
      final_hour: 1.hour.ago.utc.hour,
      "weekday_#{Time.now.utc.wday}" => true
    )
    @alarm.run event
    redirect_to alarms_path, notice: 'Alarm test sent.'
  end

  def create
    @alarm = Alarm.new(alarm_params)
    @alarm.email_recipient = nil unless @alarm.kind.email?
    respond_to do |format|
      if @alarm.save
        format.html { redirect_to alarm_path(@alarm), notice: 'Alarm was successfully created'}
      else
        format.html { render action: 'new' }
      end
    end
  end

  def update
    respond_to do |format|
      if @alarm.update(alarm_params)
        format.html { redirect_to alarm_path(@alarm), notice: 'Alarm was successfully updated' }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    @alarm.destroy
    respond_to do |format|
      format.html { redirect_to alarms_url, notice: 'Alarm has been deleted' }
    end
  end

  protected

  def set_alarm
    @alarm = Alarm.find(params[:id])
  end

  def alarm_params
    params.require(:alarm).permit([:action, :title, :email_recipient, :slack_channel, :slack_url, :message])
  end

  def sort_column
    Alarm.column_names.include?(params[:sort]) ? params[:sort] : "alarms.title"
  end

  def sort_direction
    %w[asc desc]. include?(params[:direction]) ? params[:direction] : "asc"
  end

  def alarms
    @alarms ||= begin
                  scope = Alarm.order(sort_column + ' ' + sort_direction)
                  if params[:expected_event_id]
                    scope = scope.includes(:expected_events).where('expected_events.id' => params[:expected_event_id])
                  end
                  scope.page(params[:page]).per(10)
                end
  end

end
