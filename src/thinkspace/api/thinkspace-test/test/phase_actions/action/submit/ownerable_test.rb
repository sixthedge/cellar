require 'phase_actions_helper'
module Test; module PhaseActions; class OwnerableTest < ActionController::TestCase
  include PhaseActions::Helpers::All

  describe 'assignment phase state ownerables'  do
    let (:ownerable)     {current_user}
    let (:assignment)    {get_team_assignment}
    let (:phases)        {get_team_assignment_phases}
    let (:can_update)    {false}
    describe 'read_1' do
      let (:current_user) {read_1}
      it 'ownerables' do; assert_assignment_phase_state_ownerables; end
    end
    describe 'read_2' do
      let (:current_user) {read_2}
      it 'ownerables' do; assert_assignment_phase_state_ownerables; end
    end
    describe 'update_1' do
      let (:current_user) {update_1}
      let (:can_update)   {true}
      it 'ownerables' do; assert_assignment_phase_state_ownerables; end
    end
  end

  describe 'unlock user-to-team phase'  do
    let (:ownerable)     {current_user}
    let (:current_phase) {team_phase_a}
    let (:can_update)    {false}
    let (:debug)         {false}
    describe 'read_1' do
      let (:current_user) {read_1}
      it 'next' do
        set_submit_settings(state: :complete, unlock: :next)
        process_action
        assert_phase_state(:completed)
        assert_next_phase_state_ownerables(:unlocked)
      end
    end
    describe 'read_2' do
      let (:current_user) {read_2}
      it 'next' do
        set_submit_settings(state: :complete, unlock: :next)
        process_action
        assert_phase_state(:completed)
        assert_next_phase_state_ownerables(:unlocked)
      end
    end
    describe 'update_1' do
      let (:current_user) {update_1}
      let (:can_update)   {true}
      it 'next' do
        set_submit_settings(state: :complete, unlock: :next)
        process_action
        assert_phase_state(:completed)
        assert_next_phase_state_ownerables(:unlocked)
      end
    end
  end

  describe 'unlock team-to-user phase'  do
    let (:ownerable)     {team_1}
    let (:team_users)    {team_1_users}
    let (:current_phase) {team_phase_b}
    let (:can_update)    {false}
    let (:debug)         {false}
    describe 'read_1' do
      let (:current_user) {read_1}
      it 'next' do
        set_submit_settings(state: :complete, unlock: :next)
        process_action
        assert_phase_state(:completed)
        assert_next_phase_state_ownerables(:unlocked)
        assert_next_phase_team_user_phase_state_ownerables(:unlocked)
      end
    end
    describe 'read_2' do
      let (:current_user) {read_2}
      it 'next' do
        set_submit_settings(state: :complete, unlock: :next)
        process_action
        assert_phase_state(:completed)
        assert_next_phase_state_ownerables(:unlocked)
        assert_next_phase_team_user_phase_state_ownerables(:unlocked)
      end
    end
    describe 'update_1' do
      let (:current_user) {update_1}
      let (:ownerable)    {current_user}
      let (:team_users)   {[]}
      let (:can_update)   {true}
      it 'next' do
        set_submit_settings(state: :complete, unlock: :next)
        process_action
        assert_phase_state(:completed)
        assert_next_phase_state_ownerables(:unlocked)
        assert_next_phase_team_user_phase_state_ownerables(:unlocked)
      end
    end
  end

  describe 'unlock team-to-team phase'  do
    let (:ownerable)     {team_1}
    let (:current_phase) {team_phase_d}
    let (:can_update)    {false}
    let (:debug)         {false}
    describe 'read_1' do
      let (:current_user) {read_1}
      it 'next' do
        set_submit_settings(state: :complete, unlock: :next)
        process_action
        assert_phase_state(:completed)
        assert_next_phase_state_ownerables(:unlocked)
      end
    end
    describe 'read_2' do
      let (:current_user) {read_2}
      let (:ownerable)    {team_3}
      it 'next' do
        set_submit_settings(state: :complete, unlock: :next)
        process_action
        assert_phase_state(:completed)
        assert_next_phase_state_ownerables(:unlocked)
      end
    end
    describe 'update_1' do
      let (:current_user) {update_1}
      let (:ownerable)    {current_user}
      let (:can_update)   {true}
      it 'next' do
        set_submit_settings(state: :complete, unlock: :next)
        process_action
        assert_phase_state(:completed)
        assert_next_phase_state_ownerables(:unlocked)
      end
    end
  end

end; end; end
