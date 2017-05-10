require 'phase_actions_helper'
module Test; module PhaseActions; class PhaseScoresTest < ActionController::TestCase
  include PhaseActions::Helpers::All

  describe 'phase scores'  do
    let (:current_user)    {get_user(:read_1)}
    let (:ownerable)       {current_user}
    let (:current_phase)   {get_phase(:phase_actions_phase_A)}
    let (:debug)           {false}

      it 'default score' do
        assert_submit_phase_score(2, min: 1, max: 2)
      end

      it 'default score from validation' do
        settings = {auto_score: true}
        set_submit_settings(settings)
        set_phase_settings(current_phase.settings.merge(validation))
        process_action
        assert_phase_score(5)
      end

      it 'rules score' do
        e = assert_raises() {assert_submit_phase_score(1, score_with: :rules)}
        assert_match(/not implemented/i, e.to_s)
      end

      it 'test score class' do
        settings = {auto_score: true}
        set_submit_settings(settings)
        pap.set_score_class(TestScore)
        process_action
        assert_phase_score(123)
      end

  end

  class TestScore
    def initialize(*args); end
    def process; 123; end
  end

end; end; end
