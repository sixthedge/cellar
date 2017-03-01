require 'readiness_assurance_helper'
module Test; module Controller; class ReadinessAssuranceAdminIratsToTratTest < ActionController::TestCase
  include ReadinessAssurance::Helpers::All

  add_test(Proc.new do |route|
    describe 'to trat' do
      before do; @route = route; end
      it 'no timetable trat due at' do
        assert_authorized(send_route_request)
        assert_timeable_due_at(params_irat_due_at, irat_phase, read_1)
        assert_no_timeable(trat_phase, read_1)
        assert_no_timeable(trat_phase, team_1)
        assert_phase_state(:completed, irat_phase, read_1)
        assert_phase_state(:completed, irat_phase, read_2)
        assert_phase_state(:unlocked, trat_phase, team_1)
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'to trat' do
      let(:trat_due_at)  {time_now + 10.minutes}
      before do; @route = route; end
      it 'with timetable trat due at' do
        assert_authorized(send_route_request)
        assert_timeable_due_at(params_irat_due_at, irat_phase, read_1)
        assert_no_timeable(trat_phase, read_1)
        assert_timeable_due_at(params_trat_due_at, trat_phase, team_1)
        assert_phase_state(:completed, irat_phase, read_1)
        assert_phase_state(:completed, irat_phase, read_2)
        assert_phase_state(:unlocked, trat_phase, team_1)
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'to trat' do
      let(:trat_due_at)  {time_now + 10.minutes}
      let(:response_ownerable)   {read_1}
      before do; @route = route; end
      it 'user response scores' do
        response1 = get_response
        incorrect_answers_1(response1)
        response2 = get_response(read_2)
        correct_answers(response2)
        assert_authorized(send_route_request)
        assert_phase_score(7, irat_phase, read_1)
        assert_phase_score(9, irat_phase, read_2)
        assert_timeable_due_at(params_irat_due_at, irat_phase, read_1)
        assert_no_timeable(trat_phase, read_1)
        assert_timeable_due_at(params_trat_due_at, trat_phase, team_1)
        assert_phase_state(:completed, irat_phase, read_1)
        assert_phase_state(:completed, irat_phase, read_2)
        assert_phase_state(:unlocked, trat_phase, team_1)
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'to trat' do
      let(:trat_due_at)  {time_now + 10.minutes}
      before do; @route = route; end
      it 'server events' do
        assert_authorized(send_route_request)
        assert_server_event_transition_to_phase_with_message
      end
    end
  end) # proc

  @co = new_route_config_options(tests: get_tests, test_action: :to_trat)
  @co.only :readiness_assurance, :irats
  include ReadinessAssurance::Helpers::Route::Irats

end; end; end
