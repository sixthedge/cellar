require 'readiness_assurance_helper'
module Test; module Controller; class ReadinessAssuranceSubmitIratTest < ActionController::TestCase
  include ReadinessAssurance::Helpers::All

  add_test(Proc.new do |route|
    describe 'irat submit' do
      before do; @route = route; end
      it 'team 1 users - phase[unlock: next] assessment[transition_user_team_members_on_last_user_submit: false]' do
        phase_submit_unlock_next
        transition_user_team_members_on_last_user_submit_off
        correct_answers
        assert_authorized(send_route_request)
        assert_phase_score(9, irat_phase, read_1)
        assert_phase_state :completed, irat_phase, read_1
        assert_phase_state :unlocked,  trat_phase, team_1
        assert_no_phase_state irat_phase, read_2
        set_current_user read_2
        incorrect_answers_1
        assert_authorized(send_route_request)
        assert_phase_state :completed, irat_phase, read_1
        assert_phase_state :completed, irat_phase, read_2
        assert_phase_state :unlocked,  trat_phase, team_1
        assert_phase_score(9, irat_phase, read_1)
        assert_phase_score(7, irat_phase, read_2)
        assert_no_server_event_transition_to_phase
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'irat submit' do
      before do; @route = route; end
      it 'team 1 users - phase[unlock: next_after_all_ownerables] assessment[transition_user_team_members_on_last_user_submit: true]' do
        phase_submit_unlock_next_after_all_ownerables
        transition_user_team_members_on_last_user_submit_on
        correct_answers
        assert_authorized(send_route_request)
        assert_phase_score(9, irat_phase, read_1)
        assert_phase_state :completed, irat_phase, read_1
        assert_phase_state :locked,    trat_phase, team_1
        assert_no_phase_state irat_phase, read_2
        set_current_user read_2
        incorrect_answers_1
        assert_authorized(send_route_request)
        assert_phase_state :completed, irat_phase, read_1
        assert_phase_state :completed, irat_phase, read_2
        assert_phase_state :unlocked,  trat_phase, team_1
        assert_phase_score(9, irat_phase, read_1)
        assert_phase_score(7, irat_phase, read_2)
        assert_server_event_transition_to_phase
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'irat submit' do
      before do; @route = route; end
      it 'team 1 users - phase[unlock: next_after_all_ownerables] assessment[transition_user_team_members_on_last_user_submit: false]' do
        phase_submit_unlock_next_after_all_ownerables
        transition_user_team_members_on_last_user_submit_off
        correct_answers
        assert_authorized(send_route_request)
        assert_phase_score(9, irat_phase, read_1)
        assert_phase_state :completed, irat_phase, read_1
        assert_phase_state :locked,    trat_phase, team_1
        assert_no_phase_state irat_phase, read_2
        set_current_user read_2
        incorrect_answers_1
        assert_authorized(send_route_request)
        assert_phase_state :completed, irat_phase, read_1
        assert_phase_state :completed, irat_phase, read_2
        assert_phase_state :unlocked,  trat_phase, team_1
        assert_phase_score(9, irat_phase, read_1)
        assert_phase_score(7, irat_phase, read_2)
        assert_no_server_event_transition_to_phase
      end
    end
  end) # proc

  include ReadinessAssurance::Helpers::Route::SubmitIrat

end; end; end
