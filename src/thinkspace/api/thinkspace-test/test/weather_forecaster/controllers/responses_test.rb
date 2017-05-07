require 'controller_helper'
Test::Casespace::Seed.load(config: :weather_forecaster, auto_input: true)
module Test; module Controller; class WeatherForecaterForecast < ActionController::TestCase
  include Casespace::All

  def current_day; Thinkspace::WeatherForecaster::ForecastDay.get_current_day; end

  def new_response
    Thinkspace::WeatherForecaster::Response.new(forecast_id: forecast.id, assessment_item_id: assessment_item.id, value: input_value)
  end

  def another_forecast_assessment_item
    Thinkspace::WeatherForecaster::AssessmentItem.where.not(assessment_id: assessment.id).first
  end

  def get_unlocked_forecast
    ownerable = get_let_value(:ownerable)
    assessment.find_or_create_current_day_forecast(ownerable, ownerable)
  end

  def get_assessment_item; forecast.thinkspace_weather_forecaster_assessment_items.first; end

  co = new_route_config_options
  co.only :weather_forecaster, :responses

  get_controller_route_configs(co).each do |config|
    describe config.controller_class do
      before do; @routes = config.engine_routes; end
      let(:authable)    {get_phase(:wf_phase_1)}
      let(:assessment)  {Thinkspace::WeatherForecaster::Assessment.find_by(authable: authable)}
      let(:assessment_item) {get_assessment_item}
      let(:forecast)    {get_unlocked_forecast}
      let(:base_models) {[response, forecast, assessment, assessment_item, authable]}
      let(:json_models) {[:response]}
      let(:response)    {new_response}
      let(:input_value) {{'input' => '123'}}

      describe 'valid create' do
        @config  = config
        @action  = :create
        @test_it = Proc.new {
          it 'has correct values' do
            hash  = send_route_request
            id    = json_column(hash, :response, :id).first
            value = json_column(hash, :response, :value).first
            refute_nil id, 'response has an id'
            assert_equal input_value, value, "has correct input value #{input_value}"
          end
        }
        include UserLoop
      end

      describe 'cannot create when forecast is locked' do
        @config  = config
        @action  = :create
        @test_it = Proc.new {
          it 'forecast locked' do
            forecast.state = 'locked'
            forecast.save
            hash = send_route_request
            assert_unauthorized(hash, /forecast is locked/i)
          end
        }
        include UserLoop
      end

      describe 'cannot create when input value is not a hash' do
        let(:input_value) {'123'}
        @config  = config
        @action  = :create
        @test_it = Proc.new {
          it 'not a hash' do
            hash = send_route_request
            assert_unauthorized(hash, /not a hash/i)
          end
        }
        include UserLoop
      end

      describe 'cannot create when missing input key in value' do
        let(:input_value) {{xxxx: '123'}}
        @config  = config
        @action  = :create
        @test_it = Proc.new {
          it 'no input key' do
            hash = send_route_request
            assert_unauthorized(hash, /not have an input key/i)
          end
        }
        include UserLoop
      end

      describe 'cannot create when missing forecast id' do
        @config  = config
        @action  = :create
        @test_it = Proc.new {
          it 'missing forecast id' do
            response.forecast_id = nil
            hash = send_route_request
            assert_unauthorized(hash, /has a blank association/i)
          end
        }
        include UserLoop
      end

      describe 'cannot create when missing assessment item id' do
        @config  = config
        @action  = :create
        @test_it = Proc.new {
          it 'missing assessment item id' do
            response.assessment_item_id = nil
            hash = send_route_request
            assert_unauthorized(hash, /has a blank association/i)
          end
        }
        include UserLoop
      end

      describe 'cannot create with wrong assessment item id' do
        @config  = config
        @action  = :create
        @test_it = Proc.new {
          it 'wrong assessment item id' do
            response.assessment_item_id = another_forecast_assessment_item.id
            hash = send_route_request
            assert_unauthorized(hash, /does not belong/i)
          end
        }
        include UserLoop
      end

      describe 'cannot create when duplicate response' do
        @config  = config
        @action  = :create
        @test_it = Proc.new {
          it 'duplicate response' do
            hash = send_route_request
            hash = send_route_request
            assert_unauthorized(hash, /duplicate/i)
          end
        }
        include UserLoop
      end

      describe 'update' do
        let(:response)  {record = new_response; record.save; record}
        @config  = config
        @action  = :update
        @mod     = :TestAction
        @test_it = Proc.new {
          it 'update value to abc' do
            value = {'input' => 'abc'}
            response.value = value
            hash = send_route_request
            assert_equal value, response.value, "input value updated to #{value.inspect}"
          end
        }
        include UserLoop
      end

  end; end

end; end; end
