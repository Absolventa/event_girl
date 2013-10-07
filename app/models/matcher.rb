class Matcher
  def run
    expected_events.each do |expected_event|
      track_incoming_events_for expected_event
      run_alarms_for expected_event
      # TODO return value?
    end
  end

  def expected_events
    ExpectedEvent.active.today.backward.
      reject{|event| event.alarm_notifications.today.any? }
      # OPTIMIZE: Transform #reject into a proper where statement
  end

  def incoming_events_for expected_event
    IncomingEvent.not_tracked.
      where(title: expected_event.title).
      where("created_at > ? AND created_at <= ?", Time.zone.now.beginning_of_day, expected_event.deadline)
  end

  private

  def run_alarms_for expected_event
    if incoming_events_for(expected_event).empty? and expected_event.deadline_exceeded?
      expected_event.alarm! # unless incoming_event came in during the last hour?
    end
  end

  def track_incoming_events_for expected_event
    incoming_events_for(expected_event).each(&:track!)
  end

end
