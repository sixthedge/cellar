require 'controller_helper'
Test::Casespace::Seed.load(config: :weather_forecaster, auto_input: true)
module Test; module Controller; class WeatherForecaterForecast < ActionController::TestCase
  include Casespace::All

  def current_day; Thinkspace::WeatherForecaster::ForecastDay.get_current_day; end

  def get_unlocked_forecast
    ownerable = get_let_value(:ownerable)
    assessment.find_or_create_current_day_forecast(ownerable, ownerable)
  end

  co = new_route_config_options
  co.only :weather_forecaster, :forecasts

  get_controller_route_configs(co).each do |config|
    describe config.controller_class do
      before do; @routes = config.engine_routes; end
      let(:authable)    {get_phase(:wf_phase_1)}
      let(:assessment)  {Thinkspace::WeatherForecaster::Assessment.find_by(authable: authable)}
      let(:forecast)    {get_unlocked_forecast}
      let(:base_models) {[forecast, assessment, authable]}
      let(:json_models) {[:forecast]}

      describe 'update' do
        @config = config
        @action = :update
        @mod    = :TestAction
        @test_it = Proc.new {
          it 'completed and attempts incremented' do
            hash = send_route_request
            forecast.reload
            assert_equal ownerable, forecast.ownerable, 'Ownerables are the same'
            assert_equal 1, forecast.attempts, 'Forecast attempts are incremented'
            assert_equal current_day.to_a, forecast.forecast_at.to_a, 'Forecast day is current day'
            assert_equal 'completed', forecast.state, 'Forecast state is completed'
            assert_equal [false], json_column(hash, :forecast, :is_locked), 'Forecast is not locked'
          end
        }
        include UserLoop
      end

      describe 'view' do
        let(:forecast)    {assessment.thinkspace_weather_forecaster_forecasts.find_by(ownerable: ownerable)}
        let(:base_models) {[forecast, assessment, authable]}
        let(:json_models) {[:forecasts, :responses]}
        let(:json_blank)  {:forecasts}
        @config = config
        @action = :view
        @mod    = :TestAction
        include UserLoop
      end

  end; end

end; end; end
