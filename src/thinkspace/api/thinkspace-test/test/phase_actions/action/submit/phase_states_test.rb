require 'phase_actions_helper'
module Test; module PhaseActions; class PhaseStatesTest < ActionController::TestCase
  include PhaseActions::Helpers::All

  describe 'phase states'  do
    let (:current_user)    {get_user(:read_1)}
    let (:ownerable)       {current_user}
    let (:current_phase)   {get_phase(:phase_actions_phase_A)}
    let (:debug)           {false}

      it 'complete to completed'    do; assert_submit_phase_state(:complete, :completed); end
      it 'completed'                do; assert_submit_phase_state(:completed); end
      it 'lock to locked'           do; assert_submit_phase_state(:lock, :locked); end
      it 'locked'                   do; assert_submit_phase_state(:locked); end
      it 'unlock to unlocked'       do; assert_submit_phase_state(:unlock, :unlocked); end
      it 'unlocked'                 do; assert_submit_phase_state(:unlocked); end

  end

end; end; end
