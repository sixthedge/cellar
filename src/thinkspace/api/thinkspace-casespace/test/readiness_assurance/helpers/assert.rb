module Test::ReadinessAssurance::Helpers::Assert
extend ActiveSupport::Concern
included do

  # ###
  # ### Timetable (e.g. due_at).
  # ###

  def assert_no_timeable(timeable, ownerable=nil)
    tt = get_timetable(timeable, ownerable)
    assert_nil tt, "Should not have a timetable"
  end

  def assert_timeable_due_at(time, timeable, ownerable=nil)
    tt = get_timetable(timeable, ownerable)
    refute_nil tt, "Has a timeable"
    assert_times_equal(time, tt.due_at, "Time #{time} matches timetable [id: #{tt.id}] due_at #{tt.due_at}")
  end

  def assert_times_equal(expect, actual, message='')
    assert_equal true, expect.is_a?(Time), 'expect is a Time object ' + message
    assert_equal true, actual.is_a?(Time), 'actual is a Time object ' + message
    et = expect.utc.to_i
    at = actual.utc.to_i
    assert_equal et, at, message.blank? ? "time '#{expect}' and '#{actual}' are equal" : message
  end

  # ###
  # ### Phase State.
  # ###

  def assert_server_event_phase_states(state, oables=ownerables)
    value = assert_server_event_value(:phase_states, oables)
    key   = "#{state}_phase_ids".to_sym
    assert_equal value.keys, [key], "server event has one phase state key #{key.inspect}"
    ids   = value[key]
    assert_equal [authable.id], ids, "server event phase id is correct"
  end

  # ###
  # ### Timer Server Events.
  # ###

  def assert_server_event_timer_transition_to_phase(settings={}, oables=ownerables)
    assert_server_event_timer(:transition_to_phase, settings, oables)
  end

  def assert_server_event_timer(event, settings={}, oables=ownerables)
    se, se_settings = assert_server_event_timer_settings(event, oables)
    expect = Hash.new
    settings.each {|k,v| expect[k.to_s] = v.to_s}
    assert_equal expect, se_settings, 'timer_settings are correct'
    settings[:type] == :once ? assert_server_event_timer_once(se) : assert_server_event_timer_reminder(se)
  end

  def assert_server_event_timer_once(se)
    end_at = get_let_value(:timer_end_at) || get_let_value(:due_at)
    assert_nil se.timer_start_at, 'Once timer start_at should be nil'
    refute_nil se.timer_end_at, 'Once timer end_at should not be nil'
    assert_times_equal(end_at, se.timer_end_at, 'timer end_at are the same')
  end

  def assert_server_event_timer_reminder(se)
    start_at = get_let_value(:timer_start_at)
    end_at   = get_let_value(:timer_end_at)
    unless (start_at.blank? && se.timer_start_at.blank?)
      assert_times_equal(start_at, se.timer_start_at, 'timer start_at are the same')
    end
    unless (end_at.blank? && se.timer_end_at.blank?)
      assert_times_equal(end_at, se.timer_end_at, 'timer end_at are the same')
    end
  end

  def assert_server_event_timer_settings(event, oables=ownerables)
    rooms = get_ownerable_rooms(ownerables)
    ses   = get_server_events(authable: authable, event: event).scope_by_rooms(rooms).scope_by_active_timers
    assert_equal 1, ses.length, 'should have one timer server event'
    se       = ses.first
    settings = se.timer_settings
    assert_equal true, settings.is_a?(Hash), 'server event timer settings is a hash'
    [se, settings]
  end

  # ###
  # ### Server Events.
  # ###

  def assert_server_event_transition_to_phase_with_message(oables=ownerables)
    assert_server_event_transition_to_phase(oables)
    assert_server_event_message(oables)
    assert_admin_server_event_message(oables)
  end

  def assert_server_event_transition_to_phase(oables=ownerables)
    value = assert_server_event_value(:transition_to_phase, oables)
    cid   = value[:complete_phase_ids]
    uid   = value[:unlock_phase_ids]
    tid   = value[:transition_to_phase_id]
    assert_equal true, cid.is_a?(Array), 'complete ids is an array'
    assert_equal true, uid.is_a?(Array), 'unlock ids is an array'
    assert_equal true, tid.is_a?(Integer), 'transition id is an integer'
    assert_equal [irat_phase.id], cid, 'complete the irat phase'
    assert_equal [trat_phase.id], uid, 'unloack the trat phase'
    assert_equal trat_phase.id, tid, 'transition to the trat phase'
  end

  def assert_server_event_message(oables=ownerables)
    value = assert_server_event_value(:message, oables)
    to      = value[:to]
    from    = value[:from]
    time    = value[:time]
    message = value[:message]
    assert_equal true, to.blank?, 'ownerable message should not have a "to" value'
    assert_equal true, from.is_a?(Hash), 'message from is a Hash'
    assert_equal true, time.is_a?(String), 'message time is a String'
    assert_valid_time_string(time)
    assert_equal admin.id, from[:id], 'message is from admin'
    assert_equal default_message, message, 'has the test message'
  end

  def assert_admin_server_event_message(oables=ownerables)
    value   = assert_admin_server_event_value(:message)
    o_ids   = Array.wrap(ownerables).map(&:id).sort
    to      = value[:to]
    from    = value[:from]
    time    = value[:time]
    message = value[:message]
    assert_equal true, message.present?, 'has admin message'
    assert_equal true, to.is_a?(Array), 'message to is an Array'
    assert_equal true, from.is_a?(Hash), 'message from is a Hash'
    assert_equal true, time.is_a?(String), 'message time is a String'
    assert_valid_time_string(time)
    assert_equal admin.id, from[:id], 'message is from admin'
    to_ids = to.map {|t| t[:id]}.sort
    assert_equal o_ids, to_ids, 'message to all ownerables'
    message
  end

  def assert_server_event(event, oables=ownerables)
    rooms = get_ownerable_rooms(ownerables)
    ses   = get_server_events(authable: authable, event: event).scope_by_rooms(rooms)
    assert_equal 1, ses.length, "should have one server event for event #{event.inspect} and rooms #{rooms}"
    ses.first
  end

  def assert_no_server_event_transition_to_phase(oables=ownerables); assert_no_server_event(:transition_to_phase, oables); end

  def assert_no_server_event(event, oables=ownerables)
    rooms = get_ownerable_rooms(ownerables)
    ses   = get_server_events(authable: authable, event: event).scope_by_rooms(rooms)
    assert_equal 0, ses.length, "no server event found for event #{event.inspect} and rooms #{rooms}"
  end

  def assert_server_event_value(event, oables=ownerables)
    se    = assert_server_event(event, oables)
    value = se.value
    assert_equal true, value.is_a?(Hash), 'server event value is a hash'
    value.deep_symbolize_keys
  end

  def assert_admin_server_event(event)
    rooms = get_admin_room
    ses   = get_server_events(authable: authable, event: event).scope_by_rooms(rooms)
    assert_equal 1, ses.length, 'should have one admin server event'
    ses.first
  end

  def assert_admin_server_event_value(event)
    se    = assert_admin_server_event(event)
    value = se.value
    assert_equal true, value.is_a?(Hash), 'server event value is a hash'
    value.deep_symbolize_keys
  end

  def assert_valid_time_string(time_str)
    time = (Time.parse(time_str).utc rescue nil)
    refute_nil time, "#{time_str.inspect} is a valid time string"
  end

  def get_ownerable_rooms(ownerables); ownerables.map {|o| pubsub.room_with_ownerable(assignment, o)}; end
  def get_admin_room; pubsub.room_for(assignment, :admin); end

end; end
