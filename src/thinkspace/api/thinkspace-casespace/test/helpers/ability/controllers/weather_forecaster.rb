module Test; module Ability; module Controllers; module Thinkspace; module WeatherForecaster; module Api

  module WeatherForecasterHelper
    def response_class;            ::Thinkspace::WeatherForecaster::Response; end
    def forecast_day_class;        ::Thinkspace::WeatherForecaster::ForecastDay; end
    def forecast_day_actual_class; ::Thinkspace::WeatherForecaster::ForecastDayActual; end
    def unknown_logic_error(route); route.assert_raise_any_error(/unknown logic value/i); end
    def before_save(route)
      forecast_day = route.dictionary_model(forecast_day_class)
      forecast_day.forecast_at = Time.now + 1.day  if forecast_day.present?
    end
  end

  class ForecastsController
    include WeatherForecasterHelper
    def setup_view(route); unknown_logic_error(route); end
  end
  
  class ResponsesController
    include WeatherForecasterHelper
    def setup_update(route); unknown_logic_error(route); end
    def after_save_create(route)
      response = route.model
      response.delete  if response.present?
    end
    def params_create(route); route.set_model_params_value(:value, {input: 'test_create'}); end
    def params_update(route); route.set_model_params_value(:value, {input: 'test_update'}); end
  end

  class AssessmentsController
    def params_view(route, options); route.set_params_sub_action(:forecast_attempts); end
  end

end; end; end; end; end; end
