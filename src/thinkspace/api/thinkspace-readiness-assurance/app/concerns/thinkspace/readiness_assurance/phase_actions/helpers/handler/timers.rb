module Thinkspace; module ReadinessAssurance; module PhaseActions; module Helpers; module Handler; module Timers

  AUTO_TIMER_TRANSITION_TO_ASSIGNMENT=:transition_to_assignment

  def auto_timer(options={})
    handler_error "Auto timer options is not a hash #{options.inspect}." unless options.is_a?(Hash)
    options = options.deep_symbolize_keys
    return if auto_timers_exist?(options[:event] || AUTO_TIMER_TRANSITION_TO_ASSIGNMENT)
    add_timetable = options[:timetable] != false # default to true
    duration_hash = options[:duration]
    handle_error "Auto timer duration is not a hash #{duration_hash.inspect}" unless duration_hash.is_a?(Hash)
    duration = auto_timer_hash_to_duration(duration_hash)
    handle_error "Auto timer duration is zero." if duration == 0
    ownerables = Array.wrap(options.delete(:ownerables) || current_user)
    se_options = default_auto_timer_options(ownerables, options)
    se_options.deep_merge!(options.except(:timetable, :duration))
    due_at = se_options[:timer_end_at] = (auto_timer_now + duration)
    server_event_record_class.new(se_options).publish
    if add_timetable && due_at.present?
      processor.timetable(phase, ownerables: ownerables, user: current_user, due_at: due_at)
    end
  end

  def default_auto_timer_options(ownerables, options)
    options.dig(:timer_settings, :interval).blank? ? default_auto_timer_no_reminder_options(ownerables) : default_auto_timer_reminder_options(ownerables)
  end

  def default_auto_timer_no_reminder_options(ownerables)
    options = default_auto_timer_reminder_options(ownerables)
    options.delete(:timer_start_at)
    options[:timer_settings] = {
      user_id: current_user.id,
      type:    :once,
      message: "Default phase #{phase.title.inspect} once message",
    }
    options
  end

  def default_auto_timer_reminder_options(ownerables)
    {
      origin:         self,
      authable:       phase,
      user:           current_user,
      event:          AUTO_TIMER_TRANSITION_TO_ASSIGNMENT,
      value:          {lock_phase_ids: [phase.id], transition_to_assignment_id: assignment.id},
      rooms:          assignment_ownerable_rooms(ownerables),
      timer_start_at: auto_timer_now,
      timer_settings: {
        user_id:    current_user.id,
        type:       :countdown,
        unit:       :minute,
        room_event: :timer,
        interval:   1,
        message:    "Default phase #{phase.title.inspect} reminder message",
      }
    }
  end

  def auto_timer_now; @_auto_timer_now ||= Time.now; end

  def auto_timers_exist?(event=AUTO_TIMER_TRANSITION_TO_ASSIGNMENT)
    return true if event.blank?
    get_auto_timers(event).present?
  end

  def get_auto_timers(event=AUTO_TIMER_TRANSITION_TO_ASSIGNMENT)
    server_event_class.where(authable: phase, user_id: current_user.id, room_event: :server_event, event: event)
  end

  def auto_timer_hash_to_duration(hash)
    return 0 unless hash.is_a?(Hash)
    timer = hash.symbolize_keys
    [:hours, :minutes, :seconds].each {|k| timer[k] = (timer[k] || '0').to_s.strip}
    iso = "PT#{timer[:hours]}H#{timer[:minutes]}M#{timer[:seconds]}S"
    ::ActiveSupport::Duration.parse(iso)
  end

  def cancel_auto_timers(event=AUTO_TIMER_TRANSITION_TO_ASSIGNMENT)
    timers = get_auto_timers(event)
    return if timers.blank?
    timers.each do |se|
      id = se.class.name.underscore + "/#{se.id}"
      se.cancel_timer
      server_event_record_class.new
        .save_record_off
        .origin(self)
        .authable(phase)
        .user(current_user)
        .event(:timer_cancel)
        .timer_settings(type: :cancel, cancel_id: id, user_id: current_user.id)
        .publish
    end
  end

end; end; end; end; end; end
