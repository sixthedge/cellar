require 'phase_actions_helper'
module Test; module PhaseActions; class AllOwnerablesTest < ActionController::TestCase
  include PhaseActions::Helpers::All

  def current_user; @current_user; end
  def ownerable;    @ownerable; end

  describe 'unlock user-to-team' do
    let (:current_phase)   {team_phase_a}
    it 'next_after_all_ownerables' do
      np = next_phase
      assert_equal np, team_phase_b, 'next phase should be phase_b'
      set_submit_settings(state: :complete, unlock: :next_after_all_ownerables)
      users = [read_1, read_2, read_3]
      users.each do |user|
        @current_user = user
        @ownerable    = user
        process_action
        if user == read_3
          assert_phase_state(:unlocked, next_phase, team_1)
        else
          ps = ownerable_phase_states(np, team_1)
          assert_equal true, ps.blank?, "Phase state should not exist for next phase team ownerable until last user (read_3) completes"
        end
        assert_phase_state(:completed, current_phase, ownerable)
      end
      users.each do |user|
        assert_phase_state(:completed, current_phase, user)
      end
      assert_phase_state(:unlocked, np, team_1)
      ps = ownerable_phase_states(np, team_3)
      assert_equal true, ps.blank?, "team_3 phase state not created since (read_2 is complete) but has incomplete user 'read_9'"
    end
  end

  describe 'unlock team-to-user' do
    let (:current_phase)   {team_phase_b}
    it 'next_after_all_ownerables' do
      @current_user = read_1
      set_submit_settings(state: :complete, unlock: :next_after_all_ownerables)
      [team_1].each do |team|
        @ownerable = team
        process_action
      end
      np = next_phase
      assert_equal np, team_phase_c, 'next phase should be phase_c'
      assert_phase_state(:completed, current_phase, team_1)
      [read_1, read_3].each do |user|
        assert_phase_state(:unlocked, np, user)
      end
      ps = ownerable_phase_states(np, read_2)
      assert_equal true, ps.blank?, "read_2 phase state not created since has incomplete team 'team_3'"
    end
  end

end; end; end
