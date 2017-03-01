module Thinkspace; module ReadinessAssurance; module PhaseActions
class TratHandler < BaseHandler

  def trat; self; end

  # ###
  # ### Phase States.
  # ###

  def update_phase_states
    validate_phase_state()
    ownerables = []
    teams.each do |team|
      ownerables += trat.team_users(team)
    end
    ownerables = ownerables.uniq # server events send to the assignment/user room (e.g. not assignment/team) so get all team users
    trat.phase.transaction do; update_ownerable_phase_states(ownerables); end
    publish_phase_states(ownerables, phase_state => trat.phase)
    publish_messages(teams: ownerables)
  end

end; end; end; end
