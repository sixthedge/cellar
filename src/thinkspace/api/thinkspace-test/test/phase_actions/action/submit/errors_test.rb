require 'phase_actions_helper'
module Test; module PhaseActions; class ErrorsTest < ActionController::TestCase
  include PhaseActions::Helpers::All

  def bad_pap(*args); phase_action_processor_class.new(*args); end

  def good_pap; phase_action_processor_class.new(current_phase, current_user, action: :submit); end

  def assert_error(match, *args)
    e = assert_raises() {bad_pap(*args)}
    assert_match(/#{match}/i, e.to_s)
  end

  describe 'processor errors'  do
    let (:current_user)    {get_user(:read_1)}
    let (:ownerable)       {current_user}
    let (:current_phase)   {get_phase(:phase_actions_phase_A)}
    let (:debug)           {false}

      it 'blank phase'      do; assert_error('blank', nil, :b); end
      it 'bad phase'        do; assert_error('must be', current_user, :b); end
      it 'blank user'       do; assert_error('blank', current_phase, nil); end
      it 'bad user'         do; assert_error('must be', current_phase, current_phase); end

      it 'bad phase event'  do
        e = assert_raises() {good_pap.send :send_event_to_phase, :badevent}
        assert_match(/no event.*badevent/i, e.to_s)
      end

      it 'bad phase state event'  do
        e = assert_raises() {good_pap.send :send_event_to_phase_state, ownerable, :badevent}
        assert_match(/no event.*badevent/i, e.to_s)
      end

      it 'bad processor classes'  do
        e = assert_raises() {good_pap.set_action_class(current_user)}
        assert_match(/not a class/i, e.to_s)
        e = assert_raises() {good_pap.set_action_class(:badclass)}
        assert_match(/not a class/i, e.to_s)
        e = assert_raises() {good_pap.set_score_class(:badclass)}
        assert_match(/not a class/i, e.to_s)
        e = assert_raises() {good_pap.set_lock_class(:badclass)}
        assert_match(/not a class/i, e.to_s)
        e = assert_raises() {good_pap.set_unlock_class(:badclass)}
        assert_match(/not a class/i, e.to_s)
      end

      it 'bad settings score class'  do
        set_submit_settings(auto_score: {score_with: :badclass})
        e = assert_raises() {good_pap.process_action(ownerable)}
        assert_match(/cannot be constantized/i, e.to_s)
      end
  end

end; end; end
