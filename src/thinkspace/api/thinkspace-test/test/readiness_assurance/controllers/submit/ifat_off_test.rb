require 'readiness_assurance_helper'
module Test; module Controller; class ReadinessAssuranceSubmitIratOffTest < ActionController::TestCase
  include ReadinessAssurance::Helpers::All

  add_test(Proc.new do |route|
    describe 'irat submit' do
      before do; @route = route; end
      it 'ifat off' do
        score_ifat_off
        scoring_settings(correct: 5, attempted: 2, no_answer: 0, incorrect_attempt: -1)
        incorrect_1
        assert_authorized(send_route_request)
        assert_phase_score(2, irat_phase, read_1) # attempted value
        incorrect_2
        assert_authorized(send_route_request)
        assert_phase_score(4, irat_phase, read_1) # attempted value * 2
        incorrect_3
        assert_authorized(send_route_request)
        assert_phase_score(6, irat_phase, read_1) # attempted value * 3
        correct_answers
        assert_authorized(send_route_request)
        assert_phase_score(15, irat_phase, read_1) # no deduction for incorrect attempts
        assert_equal 4, get_metadata[:number_of_updates], 'has correct number of updates'
        assert_equal Hash(ra_1_1: ['x', 'a'], ra_1_2: ['y', 'b'], ra_1_3: ['z', 'c']), get_metadata[:attempt_values]
      end
    end
  end) # proc

  add_test(Proc.new do |route|
    describe 'irat submit' do
      before do; @route = route; end
      it 'ifat off attempt values' do
        score_ifat_off
        scoring_settings(correct: 5, attempted: 2, no_answer: 0, incorrect_attempt: -1)
        incorrect_1
        assert_authorized(send_route_request)
        incorrect_2
        assert_authorized(send_route_request)
        incorrect_3
        assert_authorized(send_route_request)
        incorrect_3
        assert_authorized(send_route_request)
        assert_equal 4, get_metadata[:number_of_updates], 'has correct number of updates'
        assert_equal Hash(ra_1_1: ['x'], ra_1_2: ['y'], ra_1_3: ['z']), get_metadata[:attempt_values]
        answer_3(:w)
        assert_authorized(send_route_request)
        assert_equal 5, get_metadata[:number_of_updates], 'has correct number of updates'
        assert_equal Hash(ra_1_1: ['x'], ra_1_2: ['y'], ra_1_3: ['z', 'w']), get_metadata[:attempt_values]
        incorrect_3
        assert_authorized(send_route_request)
        assert_equal 6, get_metadata[:number_of_updates], 'has correct number of updates'
        assert_equal Hash(ra_1_1: ['x'], ra_1_2: ['y'], ra_1_3: ['z', 'w', 'z']), get_metadata[:attempt_values]
      end
    end
  end) # proc

  include ReadinessAssurance::Helpers::Route::SubmitIrat

end; end; end
