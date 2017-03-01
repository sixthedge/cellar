module Thinkspace; module Casespace; module PhaseActions; module Helpers; module Processor; module Ownerable

  def get_ownerables(phase=current_phase)
    phase.team_ownerable? ? get_teams(phase) : get_users(phase)
  end

  def get_teams(phase=current_phase); phase.thinkspace_team_teams; end

  def get_all_teams(phase=current_phase)
    get_teams + phase_assignment(phase).thinkspace_team_teams
  end

  def get_users(phase=current_phase, options={})
    roles       = [options[:roles] || :read].flatten.compact
    space       = phase.get_space()
    space_users = space_user_class.where(role: roles)
    user_ids    = space_users.pluck(:user_id)
    user_class.where(id: user_ids)
  end

  def get_user_teams(users, phase=current_phase); team_class.scope_by_teamables(phase).scope_by_users(users); end

  def get_team_users(team); team.thinkspace_common_users; end

  def phase_state_completed?(ps); ps.present? && ps.completed?; end

end; end; end; end; end; end
