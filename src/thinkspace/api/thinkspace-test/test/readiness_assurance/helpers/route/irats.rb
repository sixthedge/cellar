module Test::ReadinessAssurance::Helpers::Route::Irats
extend ActiveSupport::Concern
included do

  get_controller_route_configs(@co).each do |config|
    describe config.controller_class do
      before do; @routes = config.engine_routes; end
      let(:current_phase)  {irat_phase}
      let(:authable)       {current_phase}
      let(:current_user)   {update_1}
      let(:user)           {current_user}
      let(:ownerable)      {current_user}
      let(:admin)          {update_1}
      let(:models)         {[current_phase, current_user]}
      let(:assessment)     {get_assessment}
      let(:assignment)     {get_assignment}
      let(:params)         {get_irat_to_trat_params}
      let(:ownerables)     {[read_1, read_2]}
      # let(:print_params)   {true}
      # let(:print_json)     {true}
      # let(:debug)          {true}
      @config = config
      @action = @config.routes_config.options[:test_action]
      route   = @config.controller_action_route(@action)
      route.set_as_updater
      (@config.routes_config.options[:tests] || []).each do |t|
        t.call(route)
      end
  end; end

end; end
