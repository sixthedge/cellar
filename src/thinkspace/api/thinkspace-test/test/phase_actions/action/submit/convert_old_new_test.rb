require 'phase_actions_helper'
module Test; module PhaseActions; class ConvertOldNewTest < ActionController::TestCase
  include PhaseActions::Helpers::All

  def settings_base
    {action_submit_server: [{event: :complete_phase, phase_id: :self}, {event: :auto_score, phase_id: :self}]}
  end

  def settings_next
    {action_submit_server: [{event: :complete_phase, phase_id: :next}, {event: :auto_score, phase_id: :self}]}
  end

  def settings_prev
    {action_submit_server: [{event: :complete_phase, phase_id: :self}, {event: :auto_score, phase_id: :previous}]}
  end

  def settings_bad
    {action_submit_server: [{event: :complete_phase, phase_id: :next}, {event: :auto_score, phase_id: :previous}]}
  end

  describe 'phase action setting'  do
    let (:current_user)    {get_user(:read_1)}
    let (:current_phase)   {get_phase(:phase_actions_phase_A)}
    let (:debug)           {false}

    describe 'convert' do
      it 'basic complete and auto score' do
        set_phase_settings(settings_base)
        expect = {state: 'complete_phase', auto_score: true}.stringify_keys
        assert_equal expect, pap.action_settings
      end
      it 'unlock next' do
        set_phase_settings(settings_next)
        expect = {state: 'complete_phase', auto_score: true, unlock: 'next'}.stringify_keys
        assert_equal expect, pap.action_settings
      end
      it 'unlock previous' do
        set_phase_settings(settings_prev)
        expect = {state: 'complete_phase', auto_score: true, unlock: 'previous'}.stringify_keys
        assert_equal expect, pap.action_settings
      end
      it 'bad-both next and previous' do
        set_phase_settings(settings_bad)
        e = assert_raises() {pap.action_settings}
        assert_match(/both unlock/i, e.to_s)
      end
    end
  end

end; end; end
