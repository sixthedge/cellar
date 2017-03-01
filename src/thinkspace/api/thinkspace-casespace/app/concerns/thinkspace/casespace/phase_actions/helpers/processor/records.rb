module Thinkspace; module Casespace; module PhaseActions; module Helpers; module Processor; module Records

  def phase_assignment(phase=current_phase);         phase.thinkspace_casespace_assignment; end
  def active_assignment_phases(phase=current_phase); phase_assignment.thinkspace_casespace_phases.scope_active.order(:position); end

  def next_phases(phase=current_phase); active_assignment_phases.where('position > ?', phase.position).order(:position); end
  def prev_phases(phase=current_phase); active_assignment_phases.where('position < ?', phase.position).order(:position); end

  def next_phase(phase=current_phase); next_phases(phase).first; end
  def prev_phase(phase=current_phase); prev_phases(phase).first; end

  def get_phase_state(ownerable, phase=current_phase); phase.find_or_create_state_for_ownerable(ownerable, current_user); end
  def get_phase_score(ownerable, phase=current_phase); phase.find_or_create_score_for_ownerable(ownerable, current_user); end
  def get_phase_components(phase=current_phase);       phase.thinkspace_casespace_phase_components; end

  def get_existing_phase_state(ownerable, phase=current_phase); phase.thinkspace_casespace_phase_states.find_by(ownerable: ownerable); end

  def find_phase_components(componentable_class, phase=current_phase); get_phase_components(phase).where(componentable_type: componentable_class.name); end

  def find_componentables(componentable_class, phase=current_phase)
    get_phase_components(phase).where(componentable_type: componentable_class.name).map {|pc| pc.componentable}
  end

  def lock_phase(phase=current_phase);   send_event_to_phase(:lock, phase); end
  def unlock_phase(phase=current_phase); send_event_to_phase(:activate, phase); end

  def complete_phase_state(ownerable, phase=current_phase); send_event_to_phase_state(ownerable, :complete_phase, phase); end
  def lock_phase_state(ownerable, phase=current_phase);     send_event_to_phase_state(ownerable, :lock_phase, phase); end
  def unlock_phase_state(ownerable, phase=current_phase)   
    send_event_to_phase_state(ownerable, :unlock_phase, phase) unless phase.unlock_at(ownerable).present? # prevent unlock for phases which have an unlock date set
  end

  private

  def send_event_to_phase(event, phase=current_phase)
    debug "Sending phase event #{event.to_s.inspect}", nil, phase  if debug?
    validate_event(phase, event)
    phase.send event
    raise SaveError, "Error saving phase [id: #{phase.id}] after send event." unless phase.save
  end

  def send_event_to_phase_state(ownerable, event, phase=current_phase)
    debug "Sending phase state event #{event.to_s.inspect}", ownerable, phase  if debug?
    phase_state = get_phase_state(ownerable, phase)
    validate_event(phase_state, event)
    phase_state.send event
    raise SaveError, "Error saving phase state for phase [id: #{phase.id}] after send event '#{event.to_s}'." unless phase_state.save
    phase_state
  end

  def validate_event(record, event)
    raise EventError, "Record is blank for event '#{event}'." if record.blank?
    raise EventError, "No event '#{event}' for class '#{record.class.name}'." unless record.respond_to?(event)
  end

  def user_class;       Thinkspace::Common::User; end
  def space_user_class; Thinkspace::Common::SpaceUser; end
  def phase_class;      Thinkspace::Casespace::Phase; end
  def team_class;       Thinkspace::Team::Team; end

  class EventError < StandardError; end;
  class SaveError  < StandardError; end;

end; end; end; end; end; end
