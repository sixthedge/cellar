module Thinkspace; module Casespace; module PhaseActions; module Helpers; module Processor; module Actions

  def process_action(ownerable)
    debug "Action #{action.to_s.inspect}", ownerable if debug?
    get_action_class.new(self, ownerable).process
  end

  def action_score(ownerable, phase=current_phase)
    return unless action_auto_score? && get_action_auto_score
    auto_score(ownerable, phase)
  end

  def action_phase_state_transition(ownerable, phase=current_phase)
    state = get_action_state
    return if state.blank?
    event = map_action_state_to_event(state)
    send_event_to_phase_state(ownerable, event, phase) if event.present?
  end

  def action_lock_phase_state(ownerable, phase=current_phase)
    key = get_action_lock
    process_phase_state_event(phase, ownerable, key, :lock) if key.present?
  end

  def action_unlock_phase_state(ownerable, phase=current_phase)
    key = get_action_unlock
    process_phase_state_event(phase, ownerable, key, :unlock) if key.present?
  end

  private

  def action_auto_score?;      action_settings.has_key?(:auto_score); end
  def get_action_auto_score;   action_settings[:auto_score]; end
  def get_action_state;        action_settings[:state]; end
  def get_action_lock;         action_settings[:lock]; end
  def get_action_unlock;       action_settings[:unlock]; end

  def get_action_class
    return action_class if action_class.present?
    name = action_settings[:class]
    case
    when name.blank?
      class_name = "Thinkspace::Casespace::PhaseActions::Action::#{action.to_s.camelize}"
    when totem_settings_class?(name)
      return get_totem_settings_class(name)
    else
      class_name = "Thinkspace::Casespace::PhaseActions::Action::#{name.to_s.camelize}"
    end
    klass = class_name.safe_constantize
    raise InvalidClassError, "Action class name #{class_name.inspect} cannot be constantized." if klass.blank?
    klass
  end

  def map_action_state_to_event(state)
    case state.to_sym
    when :complete, :completed   then :complete_phase
    when :lock, :locked          then :lock_phase
    when :unlock, :unlocked      then :unlock_phase
    else state.to_sym
    end
  end

  def process_phase_state_event(phase, ownerable, key, event)
    klass  = get_phase_state_event_class(event)
    phases = klass.present? ? klass.new(self, phase, ownerable, key: key, event: event).process : get_phases_by_key(phase, key, event)
    Array.wrap(phases).each do |event_phase|
      event_phase.get_ownerables(ownerable, current_user, can_update: can_update).each do |phase_ownerable|
        call_phase_state_event(event_phase, phase_ownerable, event)
      end
    end
  end

  def get_phase_state_event_class(event)
    case event
    when :unlock then unlock_class
    when :lock   then lock_class
    else nil
    end
  end

  def call_phase_state_event(phase, ownerable, event)
    case event
    when :unlock then unlock_phase_state(ownerable, phase)
    when :lock   then lock_phase_state(ownerable, phase)
    else
      raise InvalidPhaseStateEvent, "Invalid phase state event #{event.to_s.inspect}."
    end
  end

  # ###
  # ### Phases Based on Key.
  # ###

  def get_phases_by_key(phase, key, event)
    case (key.is_a?(String) ? key.to_sym : key)
    when :next           then next_phases(phase).limit(1)
    when :next_all       then next_phases(phase)
    when :previous       then prev_phases(phase).limit(1)
    when :previous_all   then prev_phases(phase)
    when :next_after_all_ownerables      then process_after_all_ownerables(next_phase, event)
    when :previous_after_all_ownerables  then process_after_all_ownerables(prev_phase, event)
    else []
    end
  end

  # ###
  # ### After All Ownerables.
  # ###

  # Note: phases = next/prev phase(s).
  def process_after_all_ownerables(phases, event)
    current_phase_is_team_ownerable = current_phase.team_ownerable?
    [phases].flatten.compact.each do |phase|
      phase_is_team_ownerable = phase.team_ownerable? # the next/prev phase
      case
      when !current_phase_is_team_ownerable && phase_is_team_ownerable  # ### user-to-team ### #
        teams      = get_user_teams(current_user, phase) # get next/prev phase's teams to check for completed current phase users
        ownerables = get_teams_with_all_user_ownerables_completed(current_phase, teams)
      when current_phase_is_team_ownerable && !phase_is_team_ownerable  # ### team-to-user ### #
        teams      = get_user_teams(current_user, current_phase)
        ownerables = get_users_with_all_team_ownerables_completed(current_phase, teams)
      else ownerables = Array.new
      end
      Array.wrap(ownerables).each do |ownerable|
        call_phase_state_event(phase, ownerable, event)  # set next/prev phase state for ownerable
      end
    end
    [] # nothing more to do in the common event process e.g. return empty phases array
  end

  # When the current phase is user based and the next/prev phase is team based, ensure
  # all of the next/prev phase team members have completed the current phase.
  # e.g. when a current user completes, will not change the next/prev phase's phase states
  # unless all of the next/prev phase team members (for the current user teams) have also
  # completed the current phase.
  def get_teams_with_all_user_ownerables_completed(phase, teams)
    return [] if teams.blank?
    completed_teams = Array.new
    teams.each do |team|
      complete = true
      get_team_users(team).each do |user|
        ps       = get_existing_phase_state(user, phase)
        complete = false unless phase_state_completed?(ps)
      end
      completed_teams.push(team) if complete
    end
    completed_teams
  end

  # When the current phase is team based and next/prev phase is user based, only
  # change the next/prev phase's phase state for the users that have completed all
  # of their current phase teams.
  # e.g. when a user has mulitple teams for the current phase, ensure all the user's teams
  # are completed before changing the next/prev phase's phase states.
  def get_users_with_all_team_ownerables_completed(phase, teams, processed_teams=[], complete_users=[], incomplete_users=[], depth=1)
    return [] if teams.blank?
    raise TeamRecursionError, "To much team recursion" if depth > 5
    teams.each do |team|
      next if processed_teams.include?(team)
      ps    = get_existing_phase_state(team, phase)
      users = get_team_users(team)
      phase_state_completed?(ps) ? complete_users.push(users) : incomplete_users.push(users)
      users.each do |user|
        user_teams = get_user_teams(user, phase)
        more_teams = (user_teams - teams)
        next if more_teams.blank?
        get_users_with_all_team_ownerables_completed(phase, teams + more_teams, teams, complete_users, incomplete_users, depth += 1)
      end
    end
    complete_users  = [complete_users].flatten.compact.uniq
    incomplete_users = [incomplete_users].flatten.compact.uniq
    (complete_users - incomplete_users)
  end

  class TeamRecursionError     < StandardError; end
  class InvalidClassError      < StandardError; end
  class InvalidPhaseStateEvent < StandardError; end

end; end; end; end; end; end
