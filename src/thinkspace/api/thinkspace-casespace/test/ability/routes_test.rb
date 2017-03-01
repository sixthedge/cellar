require 'ability_helper'
Test::Casespace::Seed.load(config: :ability)
module Test; module Ability; class Routes < ActionController::TestCase
  include Casespace::All
  include Ability::Dictionary

  # set_test_ability_classes File.expand_path('../ability_files', __FILE__)

  co = new_route_config_options
  co.controller_helper_namespace = 'Test::Ability::Controllers'

  # co.only :common, :invitations, :fetch_state
  # co.only :artifact, :files, :create
  # co.only :casespace, :assignments, :view
  # co.only_users readers: :read_1
  # co.only_users updaters: :update_1
  # co.only_users readers: :read_1, updaters: :update_1
  # co.only_users unauthorized_readers: :read_2
  # co.only_users updaters: :update_1, unauthorized_updaters: :update_2
  # co.only_users unauthorized_updaters: :update_2

  # ###
  # ###
  # ### TODO: How handle the following exceptions so tests will pass?
  co.except :artifact, :files, :create
  co.except :common, :discourse
  co.except :common, :invitations, :resend
  co.except :common, :spaces, :invite
  co.except :markup
  co.except :resource
  co.except :team
  co.except :simulation
  # ###
  # ###
  # ###

  get_controller_route_configs(co).each do |config|
    describe config.controller_class do
      @config = config
      before do; @routes = config.engine_routes; end
      # ### Base Models:
        let(:space)        {get_space(:ability_space_1)}
        let(:assignment)   {get_assignment(:ability_assignment_1_1)}
        let(:phase)        {get_phase(:ability_phase_1_1_A)}
        let(:authable)     {phase}
        let(:base_models)  {[space, assignment, phase]}

      # ### Print Options:
        let(:report_failures_by_count)  {true}
        # let(:report_failures)           {true}
        # let(:print_params)              {true}
        # let(:print_json)                {true}
        # let(:print_params_on_failure)   {true}
        # let(:print_dictionary)          {true}
        # let(:print_dictionary_ids)      {true}

      include TestRoutes

    end
  end

end; end; end
