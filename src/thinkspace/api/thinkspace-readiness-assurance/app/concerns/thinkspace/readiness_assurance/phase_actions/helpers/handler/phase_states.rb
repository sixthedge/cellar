module Thinkspace; module ReadinessAssurance; module PhaseActions; module Helpers; module Handler; module PhaseStates

  def update_ownerable_phase_states(ownerables, state=phase_state)
    return if state.blank?
    state = state.to_sym
    ownerables.each do |ownerable|
      case state
      when :complete        then processor.complete_phase_state(ownerable, phase)
      when :lock            then processor.lock_phase_state(ownerable, phase)
      when :unlock          then processor.unlock_phase_state(ownerable, phase)
      else handler_error("Unknown phase state '#{state}' for user [id: #{user.id}].")
      end
    end
  end

  # ###
  # ### Publish.
  # ###

  def publish_transition_to_phase(ownerables, options={})
    options[:event] = :transition_to_phase
    publish_phase_states(ownerables, options)
  end

  def publish_phase_states(ownerables, options={})
    options.symbolize_keys!
    value = pubsub_phase_states_value(options)
    rooms = assignment_ownerable_rooms(ownerables)
    event = options[:event] || :phase_states
    server_event_record_class.new
      .on_error(error_class)
      .origin(self)
      .authable(phase)
      .user(current_user)
      .rooms(rooms)
      .event(event)
      .records(options[:records])
      .value(value)
      .timer_settings(timer_settings)
      .timer_start_at(timer_start_at)
      .timer_end_at(timer_end_at)
      .publish
  end

  def pubsub_phase_states_value(options)
    value    = Hash.new
    complete = options[:complete]
    unlock   = options[:unlock]
    lock     = options[:lock]
    to       = options[:to]
    # set value when present
    value[:complete_phase_ids]     = Array.wrap(complete).map(&:id) if complete.present?
    value[:lock_phase_ids]         = Array.wrap(lock).map(&:id)     if lock.present?
    value[:unlock_phase_ids]       = Array.wrap(unlock).map(&:id)   if unlock.present?
    value[:transition_to_phase_id] = to.id                          if to.present?
    value.blank? ? nil : value
  end

  def validate_phase_state
    handler_error "Phase state is blank." if phase_state.blank?
    handler_error "Invalid phase state #{phase_state}." unless [:complete, :lock, :unlock].include?(phase_state.to_sym)
  end

  def humanized_phase_state(state=phase_state)
    state.to_s + (state.to_s.end_with?('e') ? 'd' : 'ed')
  end

end; end; end; end; end; end
