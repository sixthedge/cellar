require 'phase_actions_helper'
module Test; module Controller; class PhasesControllerTest < ActionController::TestCase
  include PhaseActions::Helpers::All

  co = new_route_config_options
  co.only :casespace, 'api/phases'
  co.only_users readers: :read_1

  get_controller_route_configs(co).each do |config|
    describe config.controller_class do
      before do; @routes = config.engine_routes; end
      let(:current_phase)  {get_phase(:phase_actions_phase_A)}
      let(:authable)       {current_phase}
      let(:current_user)   {get_user(:read_1)}
      let(:user)           {current_user}
      let(:ownerable)      {current_user}
      let(:debug)          {false}
      let(:models)         {[current_phase, current_user]}

      # let(:print_params)   {true}
      # let(:print_json)     {true}

      @config = config
      @action = :submit
      route = @config.controller_action_route(@action)
      route.set_as_reader

      describe "phase state" do
        before do; @route = route; end
        it 'submit' do
          set_next_phase_states_state(:locked)
          set_submit_settings(state: :completed, unlock: :next)
          send_route_request
          assert_phase_state(:completed)
          assert_next_phase_state(:unlocked)
          next_phases(next_phase).each {|phase| assert_phase_state(:locked, phase)}
        end
      end

      describe "phase state and score" do
        before do; @route = route; end
        it 'submit' do
          set_next_phase_states_state(:locked)
          settings = {state: :completed, unlock: :next, auto_score: true}
          set_submit_settings(settings)
          set_phase_settings(current_phase.settings.merge(validation))
          send_route_request
          assert_phase_score(5)
          assert_phase_state(:completed)
          assert_next_phase_state(:unlocked)
          next_phases(next_phase).each {|phase| assert_phase_state(:locked, phase)}
        end
      end

  end; end

end; end; end
