module Thinkspace; module ReadinessAssurance; module PhaseActions; module Helpers; module Handler; module Timers

  def auto_timer(options={})
    handler_error "Auto timer options is not a hash #{options.inspect}." unless options.is_a?(Hash)
    add_timetable = options.delete(:timetable) != false
    ownerables    = Array.wrap(options.delete(:ownerables) || current_user)
    se_options    = default_auto_timer_options(ownerables).deep_merge(options.deep_symbolize_keys)
    return if auto_timer_exists?(se_options[:event])
    release_at = se_options[:timer_start_at]
    due_at     = se_options[:timer_end_at]
    server_event_record_class.new(se_options).publish
    if add_timetable && (release_at.present? || due_at.present?)
      processor.timetable(phase, ownerables: ownerables, user: current_user, due_at: due_at, release_at: release_at)
    end
  end

  def default_auto_timer_options(ownerables)
    {
      origin:         self,
      authable:       phase,
      user:           current_user,
      event:          :transition_to_assignment,
      value:          {lock_phase_ids: [phase.id], transition_to_assignment_id: assignment.id},
      rooms:          assignment_ownerable_rooms(ownerables),
      timer_start_at: auto_timer_now,
      timer_end_at:   auto_timer_now + 5.minutes,
      timer_settings: {
        user_id:    current_user.id,
        type:       :countdown,
        unit:       :minute,
        room_event: :timer,
        interval:   1,
        message:    "Default phase #{phase.title.inspect} time message",
      }
    }
  end

  def auto_timer_now; @_auto_timer_now ||= Time.now; end

  def auto_timer_exists?(event)
    return true if event.blank?
    get_auto_timer(event).present?
  end

  def get_auto_timer(event)
    server_event_class.scope_by_active_timers.where(authable: phase, user_id: current_user.id, room_event: :server_event, event: event)
  end

  def auto_timer_hash_to_duration(hash)
    return 0 unless hash.is_a?(Hash)
    timer = hash.symbolize_keys
    [:hours, :minutes, :seconds].each {|k| timer[k] = (timer[k] || '0').to_s.strip}
    iso = "PT#{timer[:hours]}H#{timer[:minutes]}M#{timer[:seconds]}S"
    ::ActiveSupport::Duration.parse(iso)
  end

end; end; end; end; end; end
