#########################################################################################
# ###
# ### Weather Forecaster Phase Componentable.
# ###
def casespace_seed_config_add_weather_forecasters(config)
  wf_hash = config[:weather_forecaster]
  return if wf_hash.blank?
  seed_config_message('++Adding seed config weather forecaster assessments.', config)
  create_casespace_weather_forecaster_assessments(config, wf_hash)
  create_casespace_weather_forecaster_forecast_days(config, wf_hash)
end

def create_casespace_phase_componentable_weather_forecaster(phase, section, common_component, config)
  @seed.model_class(:weather_forecaster, :assessment).find_by(authable: phase)
end

def post_casespace_phase_componentables_weather_forecaster
end

def create_casespace_weather_forecaster_assessments(config, wf_hash)
  assessments = wf_hash[:assessments]
  return if assessments.blank?
  assignment = nil
  phase      = nil
  items      = nil
  station    = nil
  assessments.each do |hash|
    title = hash[:assignment]
    if title.present?
      assignment = find_casespace_assignment(title: title)
      seed_config_error "Weather forecast assignment #{title.inspect} not found [#{hash.inspect}].", config  if assignment.blank?
    else
      seed_config_error "Weather forecast assignment has not been specified and is not inheritable [#{hash.inspect}].", config  if assignment.blank?
    end
    title = hash[:phase]
    if title.present?
      phase = find_casespace_phase(title: title, assignment_id: assignment.id)
      seed_config_error "Weather forecast phase #{title.inspect} not found [#{hash.inspect}].", config  if phase.blank?
    else
      seed_config_error "Weather forecast phase has not been specified and is not inheritable [#{hash.inspect}].", config  if phase.blank?
    end
    item_names = hash[:items]
    if item_names.present?
      items = Array.new
      [item_names].flatten.compact.each do |name|
        name = 'QUE_' + name.to_s  unless name.to_s.match('QUE')
        item = @seed.model_class(:weather_forecaster, :item).find_by(name: name)
        seed_config_error "Weather forecast item #{name.inspect} not found [#{hash.inspect}].", config  if item.blank?
        items.push item
      end
    else
      seed_config_error "Weather forecast items have not been specified and is not inheritable [#{hash.inspect}].", config  if items.blank?
    end
    station_code = hash[:station]
    if station_code.present?
      station = @seed.model_class(:weather_forecaster, :station).find_by(location: station_code)
      seed_config_error "Weather forecast station #{station_code.inspect} not found [#{hash.inspect}].", config  if station.blank?
    else
      seed_config_error "Weather forecast station has not been specified and is not inheritable [#{hash.inspect}].", config  if station.blank?
    end
    title = hash[:title]
    seed_config_error "Weather forecast assessment title is blank [#{hash.inspect}].", config  if title.blank?
    assessment = create_weather_forecaster_assessment(
      title:    title,
      authable: phase,
      station:  station,
    )
    override_keys = [:title, :presentation, :help_tip]
    merge_keys    = [:processing]
    items.each do |item|
      item_attributes = item.attributes.deep_symbolize_keys.except(:id, :created_at, :updated_at)
      override_keys.each do |key|
        item_attributes[key] = hash[key]  if hash.has_key?(key)
      end
      merge_keys.each do |key|
        item_attributes[key] = (item_attributes[key] || Hash.new).deep_merge(hash[key].deep_symbolize_keys)  if hash.has_key?(key)
      end
      create_weather_forecaster_assessment_item(item_attributes.merge(assessment: assessment, item: item, station: station))
    end
  end
end

def create_casespace_weather_forecaster_forecast_days(config, wf_hash)
  forecast_days = wf_hash[:forecast_days]
  return if forecast_days.blank?
  forecast_day_class = @seed.model_class(:weather_forecaster, :forecast_day)
  forecast_days.each do |hash|
    days       = hash[:start] || 0
    start_date = Time.now + days.to_i.days
    count      = hash[:count]
    if count.blank?
      now        = Time.now
      count      = now > start_date ? (now.to_date - start_date.to_date) : (start_date.to_date - now.to_date)
      start_date = start_date + 1.days  # include run date as the final date
    end
    count.to_i.times do |i|
      forecast_day_class.find_or_create_forecast_day(start_date + i.days)
    end
  end
end
