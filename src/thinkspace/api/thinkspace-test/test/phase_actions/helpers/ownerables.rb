module Test::PhaseActions::Helpers::Ownerables
extend ActiveSupport::Concern
included do

  def get_team_assignment_phases; assignment.thinkspace_casespace_phases; end

  def get_team_assignment
    title = :phase_actions_team_assignment
    get_assignment(title) || raise("Assignment with title #{title.to_s.inspect} not found.")
  end

  def get_team(title); team_class.find_by(title: title) || raise("Team with title #{title.to_s.inspect} not found."); end

  def get_user_teams(username)
    user = get_user(username)
    team_class.scope_by_users(users)
  end

  def ownerable_phase_states(phase=current_phase, phase_ownerable=ownerable); phase.thinkspace_casespace_phase_states.where(ownerable: phase_ownerable); end
  
  def ownerable_phase_scores(phase=current_phase, phase_ownerable=ownerable)
    states = ownerable_phase_states(phase, phase_ownerable)
    states.each {|state| state.thinkspace_casespace_phase_score}
  end

  def phase_ownerables_map
    @phase_ownerables_map ||= begin
      hash               = Hash.new
      hash[team_phase_a] = get_phase_user_ownerables_map
      hash[team_phase_b] = get_phase_team_ownerables_map
      hash[team_phase_c] = get_phase_user_ownerables_map
      hash[team_phase_d] = get_phase_team_ownerables_map
      hash[team_phase_e] = get_phase_team_ownerables_map
      hash
    end
  end

  def team_phase_a; @_team_phase_a ||= get_phase(:phase_actions_noteam_phase_A); end
  def team_phase_b; @_team_phase_b ||= get_phase(:phase_actions_team_phase_B); end
  def team_phase_c; @_team_phase_c ||= get_phase(:phase_actions_noteam_phase_C); end
  def team_phase_d; @_team_phase_d ||= get_phase(:phase_actions_team_phase_D); end
  def team_phase_e; @_team_phase_e ||= get_phase(:phase_actions_team_phase_E); end

  def get_phase_user_ownerables_map
    hash           = Hash.new
    hash[read_1]   = [read_1]
    hash[read_2]   = [read_2]
    hash[read_3]   = [read_3]
    hash[update_1] = [update_1]
    hash
  end

  def get_phase_team_ownerables_map
    hash           = Hash.new
    hash[read_1]   = [team_1]
    hash[read_2]   = [team_1, team_3]
    hash[read_3]   = [team_1]
    hash[update_1] = [update_1]  # not on any teams but can update so should get a 'user' ownerable phase state
    hash
  end

  def read_1;   @_read_1   ||= get_user(:read_1); end
  def read_2;   @_read_2   ||= get_user(:read_2); end
  def read_3;   @_read_3   ||= get_user(:read_3); end
  def update_1; @_update_1 ||= get_user(:update_1); end

  def team_1; @_team_1 ||= get_team(:phase_action_team_1); end
  def team_2; @_team_2 ||= get_team(:phase_action_team_2); end
  def team_3; @_team_3 ||= get_team(:phase_action_team_3); end

  def team_1_users; @_team_1_users ||= [get_user(:read_1), get_user(:read_2), get_user(:read_3)]; end
  def team_2_users; @_team_2_users ||= [get_user(:read_4), get_user(:read_5), get_user(:read_6)]; end
  def team_3_users; @_team_3_users ||= [get_user(:read_9), get_user(:read_2)]; end

end; end
