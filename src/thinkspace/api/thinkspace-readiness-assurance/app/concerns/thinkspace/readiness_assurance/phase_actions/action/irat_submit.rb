module Thinkspace; module ReadinessAssurance; module PhaseActions; module Action
class IratSubmit < Thinkspace::Casespace::PhaseActions::Action::Submit

  attr_reader :irat, :trat

  def process
    @irat = irat_handler_class.new(processor.current_phase, current_user, {}, processor)
    process_auto_timer
    if transition_team_members?
      completed_teams = get_ownerable_completed_teams
      if completed_teams.present?
        team_ids = completed_teams.map(&:id)
        @trat    = trat_handler_class.new(irat.next_trat_phase, current_user, {team_ids: team_ids}, processor)
        irat.to_trat(trat)
      else
        super # do normal submit (e.g. not all teams members have submitted the irat phase)
      end
    else
      super # do normal submit (e.g. settings without transition team members)
    end
  end

  private

  def process_auto_timer
    return unless irat.assessment.auto_timer?
    irat.cancel_auto_timers
  end

  def transition_team_members?
    settings = (irat.assessment.settings || Hash.new).deep_symbolize_keys
    settings.dig(:submit, :transition_user_team_members_on_last_user_submit) == true
  end

  def get_ownerable_completed_teams
    teams = processor.get_user_teams(ownerable, irat.next_trat_phase)
    return [] if teams.blank?
    completed_teams = Array.new
    teams.each do |team|
      complete = true
      processor.get_team_users(team).each do |user|
        next if user == ownerable  # skip since phase state hasn't been updated yet
        ps       = processor.get_existing_phase_state(user, irat.phase)
        complete = false unless processor.phase_state_completed?(ps)
      end
      completed_teams.push(team) if complete
    end
    completed_teams
  end

  include Helpers::Handler::Classes

end; end; end; end; end
