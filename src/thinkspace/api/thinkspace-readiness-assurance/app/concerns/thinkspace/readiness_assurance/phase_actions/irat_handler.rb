module Thinkspace; module ReadinessAssurance; module PhaseActions
class IratHandler < BaseHandler

  def irat; self; end # convience method to allow methods such as 'irat.phase' instead of just 'phase' (can be clearer when also using 'trat.phase')

  # ###
  # ### Phase States.
  # ###

  def update_phase_states
    validate_phase_state()
    ownerables = users
    irat.phase.transaction do; update_ownerable_phase_states(ownerables); end
    publish_phase_states(ownerables, phase_state => irat.phase)
    publish_messages(users: ownerables)
  end

  # ###
  # ### To TRAT.
  # ###

  def to_trat(trat)
    processor.set_action(:submit)
    trat_teams = trat.teams
    trat_users = Array.new
    irat.phase.transaction do
      trat_teams.each do |team|
        team_users(team).each do |user|
          processor.complete_phase_state(user)
          processor.auto_score(user)
          trat_users.push(user) 
        end
        processor.unlock_phase_state(team, trat.phase)
      end
      if irat.timetables? || trat.timetables?
        all = trat.all_teams?
        irat.timetables(trat_users, all)
        trat.timetables(trat_teams, all)
      end
    end
    publish_transition_to_phase(trat_users, complete: irat.phase, unlock: trat.phase, to: trat.phase)
    publish_messages(users: trat_users)
  end

end; end; end; end
