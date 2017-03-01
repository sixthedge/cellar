class AutoInputForecasts < AutoInputBase

  def process(options)
    roles            = [options[:roles]].flatten.compact
    user_format_col  = options[:user_format_col] || :first_name
    number_days      = options[:days]
    users            = options[:users]
    include_unlocked = options[:include_unlocked] == true  # defaults to false e.g. only create a forecast for locked days
    completed_days   = options[:completed_days]  # number of forecast days from current day to set the forecast state as 'completed'

    if (names = [users].flatten.compact).present?
      users = get_common_users_from_first_names(names)
    end

    assessment_class   = @seed.model_class(:weather_forecaster, :assessment)
    forecast_class     = @seed.model_class(:weather_forecaster, :forecast)
    forecast_day_class = @seed.model_class(:weather_forecaster, :forecast_day)
    response_class     = @seed.model_class(:weather_forecaster, :response)

    assessments = assessment_class.all.order(:id)

    forecast_days = forecast_day_class.all.order(:forecast_at)
    forecast_days = forecast_days.select {|d| d.is_locked?}  unless include_unlocked
    if number_days.present?
      index         = number_days.to_i * -1
      forecast_days = forecast_days.slice(index, forecast_days.length)
    end
    if completed_days.present?
      index                   = completed_days.to_i * -1
      forecast_days_completed = forecast_days.slice(index, forecast_days.length)
    else
      forecast_days_completed = forecast_days  # mark all as completed
    end

    assessments.each do |assessment|
      phase = assessment.authable
      next unless include_model?(phase)
      ownerables = get_phase_ownerables(phase)
      ownerables = ownerables.select {|o| users.include?(o)}  if users.present?
      items      = @seed.get_association(assessment, :weather_forecaster, :assessment_items)
      format_col = phase.team_ownerable? ? :title : user_format_col

      ownerables.each do |ownerable|

        # Create forecasts for each day for ownerable.
        forecasts = Array.new
        forecast_days.each do |forecast_day|
          forecast = @seed.get_association(assessment, :weather_forecaster, :forecasts).find_ownerable_day(ownerable, forecast_day.forecast_at)
          if forecast.blank?
            forecast = create_weather_forecaster_forecast(
              assessment:      assessment,
              ownerable:       ownerable,
              forecast_day_id: forecast_day.id,
              user_id:         ownerable.id,
              state:           forecast_days_completed.include?(forecast_day) ? 'completed' : forecast_day.state
            )
          end
          forecasts.push(forecast)
        end

        temp     = 60
        wspeed   = 10
        forecasts.each do |forecast|
          # Create responses for each forecast's assessment item.
          # Radio and checkbox values are selected by random.
          items.each do |assessment_item|
            item        = @seed.get_association(assessment_item, :weather_forecaster, :item)
            metadata    = (item.response_metadata || {}).deep_symbolize_keys
            validations = metadata[:validations] || {}
            choices     = metadata[:choices] || []
            r           = choices.length - 1
            case metadata[:type]
            when 'input'
              if validations[:numericality].present?
                case
                when item.score_var.match(/^TEMP/i)
                  value = (temp += 1).to_s
                when item.score_var.match(/^WSPD/i)
                  value = (wspeed += 1).to_s
                else
                  value = '1'
                end
              end
            when 'radio'
              index = Random.new.rand(0..r)
              value = (choices[index] || {})[:id]
            when 'checkbox'
              value = []
              ids   = choices.collect {|c| c[:id]}
              num   = Random.new.rand(1..ids.length)
              num.times do
                index = Random.new.rand(0..r)
                value.push(ids[index])  unless value.include?(ids[index])
              end
            else
              @seed.error "Unknown asssessment item response type #{metadata.inspect}."
            end

            options = {
              forecast:        forecast,
              assessment_item: assessment_item,
              value:           {input: value},
            }

            response = @seed.new_model(:weather_forecaster, :response, options)
            @seed.create_error(response)  unless response.save
          end

        end
      end
    end

  end

end # AutoInputForecasts
