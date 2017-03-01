module Thinkspace; module Casespace; module PhaseActions; module Action; class Submit < Base

  def process
    processor.action_phase_state_transition(ownerable)
    processor.action_score(ownerable)
    processor.action_unlock_phase_state(ownerable)
    processor.action_lock_phase_state(ownerable)
    super
  end

end; end; end; end; end
