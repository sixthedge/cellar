module Test::PhaseActions::Helpers::Assert
extend ActiveSupport::Concern
included do

  def assert_no_phase_state(phase=current_phase, ps_ownerable=ownerable)
    ps = ownerable_phase_states(phase, ps_ownerable)
    assert_equal 0, ps.length, "Ownerable #{ps_ownerable.title.inspect} does not have a phase state"
  end

  def assert_phase_state(state, phase=current_phase, ps_ownerable=ownerable)
    ps = ownerable_phase_states(phase, ps_ownerable)
    assert_equal 1, ps.length, "Ownerable #{ps_ownerable.title.inspect} has phase state"
    ps = ps.first
    assert_equal state.to_s, ps.current_state
  end

  def assert_phase_score(score, phase=current_phase, ps_ownerable=ownerable)
    score = BigDecimal(score.to_s)
    ps    = ownerable_phase_scores(phase, ps_ownerable)
    assert_equal 1, ps.length, "Ownerable #{ps_ownerable.title.inspect} has phase score"
    ps = ps.first
    assert_equal score, ps.score
  end

  def assert_next_phase_state(state, phase=current_phase, ps_ownerable=ownerable)
    phase = next_phase(phase)
    ps    = ownerable_phase_states(phase, ps_ownerable)
    assert_equal 1, ps.length, "Ownerable #{ps_ownerable.title.inspect} has next phase state"
    ps = ps.first
    assert_equal state.to_s, ps.current_state
  end

  def assert_prev_phase_state(state, phase=current_phase, ps_ownerable=ownerable)
    phase = prev_phase(phase)
    ps    = ownerable_phase_states(phase, ps_ownerable)
    assert_equal 1, ps.length, "Ownerable #{ps_ownerable.title.inspect} has prev phase state"
    ps = ps.first
    assert_equal state.to_s, ps.current_state
  end

  def assert_assignment_phase_state_ownerables
    expect_states = Array.new
    phases.each do |phase|
      expect = phase_ownerables_map.dig(phase, ownerable) || []
      actual = phase.get_ownerables(ownerable, current_user, can_update: can_update, user_ownerables: true)
      assert_equal expect.sort, actual.sort, 'should have correct ownerables defined in map'
      phase_states = phase.get_phase_states(ownerable, current_user, can_update: can_update)
      assert_equal expect.length, phase_states.length, 'should have a phase state for each ownerable'
      expect_states += phase_states
    end
    actual_states = assignment.get_phase_states(phases, ownerable, current_user, can_update: can_update, user_ownerables: true)
    assert_equal expect_states.sort, actual_states.sort, 'assignment level phase states equal the phases phase states'
  end

  def assert_next_phase_state_ownerables(state)
    phase        = next_phase
    expect       = phase_ownerables_map.dig(phase, current_user) || []
    expect       = expect.select {|o| o == ownerable} if ownerable.is_a?(team_class) && phase.team_ownerable?  # only one for team-to-team
    phase_states = phase.thinkspace_casespace_phase_states.where(ownerable: expect)
    assert_equal expect.length, phase_states.length, 'should have phase state for each ownerable'
    phase_states.each do |ps|
      assert_equal state.to_s, ps.current_state
    end
  end

  def assert_next_phase_team_user_phase_state_ownerables(state)
    phase        = next_phase
    expect       = team_users
    phase_states = phase.thinkspace_casespace_phase_states.where(ownerable: expect)
    assert_equal expect.length, phase_states.length, 'should have phase state for each team member ownerable'
    phase_states.each do |ps|
      assert_equal state.to_s, ps.current_state
    end
  end

end; end
