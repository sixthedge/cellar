module TestThinkspace
  module Authorization
    module ThinkspaceWeatherForecaster

      def thinkspace_weather_forecaster_assessment_class;              Thinkspace::WeatherForecaster::Assessment; end
      def thinkspace_weather_forecaster_assessment_item_class;         Thinkspace::WeatherForecaster::AssessmentItem; end
      def thinkspace_weather_forecaster_forecast_class;                Thinkspace::WeatherForecaster::Forecast; end
      def thinkspace_weather_forecaster_forecast_day_class;            Thinkspace::WeatherForecaster::ForecastDay; end
      def thinkspace_weather_forecaster_forecast_item_class;           Thinkspace::WeatherForecaster::Item; end
      def thinkspace_weather_forecaster_forecast_response_class;       Thinkspace::WeatherForecaster::Response; end
      def thinkspace_weather_forecaster_forecast_response_score_class; Thinkspace::WeatherForecaster::ResponseScore; end
      def thinkspace_weather_forecaster_forecast_station_class;        Thinkspace::WeatherForecaster::Station; end

      def thinkspace_weather_forecaster_ability
        can [:read], thinkspace_weather_forecaster_assessment_class
        can [:read], thinkspace_weather_forecaster_assessment_item_class
        can [:read], thinkspace_weather_forecaster_forecast_day_class
        can [:read], thinkspace_weather_forecaster_forecast_item_class
        can [:read], thinkspace_weather_forecaster_forecast_station_class
        can [:crud], thinkspace_weather_forecaster_forecast_class
        can [:crud], thinkspace_weather_forecaster_forecast_response_class
        can [:read], thinkspace_weather_forecaster_forecast_response_score_class
        can [:current_forecast], thinkspace_weather_forecaster_assessment_class
      end

    end
  end
end
