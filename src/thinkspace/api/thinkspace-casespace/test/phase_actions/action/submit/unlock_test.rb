require 'phase_actions_helper'
module Test; module PhaseActions; class UnlockTest < ActionController::TestCase
  include PhaseActions::Helpers::All

  describe 'unlock' do
    let (:current_user)    {get_user(:read_1)}
    let (:ownerable)       {current_user}
    let (:current_phase)   {get_phase(:phase_actions_phase_B)}
    let (:debug)           {false}

      it 'next' do
        set_submit_settings(state: :complete, unlock: :next)
        process_action
        assert_phase_state(:completed)
        assert_next_phase_state(:unlocked)
      end

      it 'next_all' do
        set_submit_settings(state: :complete, unlock: :next_all)
        process_action
        assert_phase_state(:completed)
        next_phases.each {|phase| assert_phase_state(:unlocked, phase)}
      end

      it 'previous_all' do
        set_submit_settings(state: :complete, unlock: :previous_all)
        process_action
        assert_phase_state(:completed)
        prev_phases.each {|phase| assert_phase_state(:unlocked, phase)}
      end

      it 'previous' do
        set_submit_settings(state: :complete, unlock: :previous)
        process_action
        assert_phase_state(:completed)
        assert_prev_phase_state(:unlocked)
      end

      describe 'next on last phase' do
        let (:current_phase)   {get_phase(:phase_actions_phase_D)}
        it 'next' do
          set_submit_settings(state: :complete, unlock: :next)
          process_action
          assert_phase_state(:completed)
        end
      end

      describe 'previous on first phase' do
        let (:current_phase)   {get_phase(:phase_actions_phase_A)}
        it 'next' do
          set_submit_settings(state: :complete, unlock: :previous)
          process_action
          assert_phase_state(:completed)
        end
      end

  end

end; end; end
