require 'controller_helper'
Test::Casespace::Seed.load(config: :weather_forecaster, auto_input: true)
module Test; module Controller; class WeatherForecaterAssessment < ActionController::TestCase
  include Casespace::All

  co = new_route_config_options
  co.only :weather_forecaster, :assessments

  get_controller_route_configs(co).each do |config|
    describe config.controller_class do
      before do; @routes = config.engine_routes; end
      let(:authable)    {get_phase(:wf_phase_1)}
      let(:assessment)  {Thinkspace::WeatherForecaster::Assessment.find_by(authable: authable)}
      let(:base_models) {[assessment, assessment.thinkspace_weather_forecaster_forecasts.first, authable]}
      let(:json_models) {[:assessment, :assessment_items, :items, :stations]}

      describe 'show' do
        @config = config
        @action = :show
        @mod    = :TestAction
        include UserLoop
      end

      describe 'current_forecast' do
        let(:json_models) {[:assessments, :forecast, :responses]}
        let(:json_blank)  {:assessments}
        let(:forecast_scope) {assessment.thinkspace_weather_forecaster_forecasts.find_ownerable_current_day(ownerable)}
        @config = config
        @action = :current_forecast
        @mod    = :TestAction
        include UserLoop
      end

      describe 'forecast attempts' do
        let(:sub_action)     {:forecast_attempts}
        let(:json_models)    {[:assessments, :forecasts]}
        let(:json_blank)     {:assessments}
        let(:forecast_scope) {assessment.previous_forecasts(ownerable)}
        @config = config
        @action = :view
        @mod    = :TestAction
        include UserLoop
      end

      describe 'top forecasts' do
        before do; @route = config.controller_action_route(:view); end
        let(:sub_action) {:top_forecasts}
        @config  = config
        @action  = :view
        @test_it = Proc.new {
          it 'json includes top forecasts' do
            hash   = send_route_request
            key    = 'top_forecasts'
            num    = 10
            assert_equal [key], hash.keys.sort, "json includes only key #{key.inspect}"
            assert_equal true,  hash.keys.length <= 10, "number of top scores is less than or equal to #{num}"
          end
        }
        include UserLoop
      end

  end; end

end; end; end
