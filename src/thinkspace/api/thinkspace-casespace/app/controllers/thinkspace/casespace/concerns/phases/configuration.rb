module Thinkspace; module Casespace; module Concerns; module Phases; module Configuration
  # ###
  # ### Phase Configuration Manager
  # ###
  # The general approach is to build a new settings hash from scratch on each update.
  # 
  # Each portion can allow or disallow changes based on the `@builder_abilities` hash, dictated by the componentables.
  # => If the `@builder_abilities` do not allow a change, the value will be pulled from the existing settings instead of params.
  # => If the `@builder_abilities` does allow the change, it will be pulled from `@params_configuration` which are passed in from the UI.
  #   => Intelligent defaults need to be used when setting UI values, so a common method (`get_params_configuration_value`) is used.

  # ### Configuration helpers
  def update_phase_configuration
    # Load configuration hash from params.
    return unless params.has_key?(:configuration)
    params_settings = get_configuration_settings_from_params
    @phase.settings = params_settings
    @phase.save
  end

  def get_configuration_settings_from_params
    settings = Hash.new
    add_validation(settings)
    add_phase_score_validation(settings)
    add_submit(settings)
    add_actions_submit(settings)
    settings.with_indifferent_access
  end

  # ### Input validation
  def add_validation(settings)
    validation = Hash.new
    if @builder_abilities[:configuration_validate]
      validation[:validate] = get_params_configuration_value(:configuration_validate)
    else
      validation[:validate] = get_configuration_settings_value(:validation, :validate)
    end
    settings[:validation] = validation
  end

  # ### Phase score validation
  def add_phase_score_validation(settings)
    validation = Hash.new
    if @builder_abilities[:max_score]
      validation[:numericality] = { less_than_or_equal_to: get_params_configuration_value(:max_score) }
    else
      validation[:numericality] = { less_than_or_equal_to: get_configuration_settings_value(:phase_score_validation, :numericality, :less_than_or_equal_to) }
    end
    settings[:phase_score_validation] = validation
  end

  # ### Submit button
  def add_submit(settings)
    # TODO: Refactor once the location of this setting is finalized.
    settings[:submit] = { visible: get_params_configuration_value(:submit_visible), text: get_params_configuration_value(:submit_text) }
  end

  # ### Action submit server configuration helpers
  def add_action_submit_server(settings)
    settings[:action_submit_server] = Array.new
    add_action_submit_server_events(settings)
  end

  def add_actions_submit(settings)
    submit_settings              = Hash.new
    submit_settings[:unlock]     = :next if @builder_abilities[:unlock_phase] && @params_configuration[:unlock_phase]
    # Leaving the `if` off, since we want all settings to include completion for now.
    submit_settings[:state]      = :complete # if @builder_abilities[:complete_phase] && @params_configuration[:complete_phase]
    submit_settings[:auto_score] = @params_configuration[:auto_score] if @builder_abilities[:auto_score]
    settings[:actions] ||= Hash.new
    settings[:actions][:submit] = submit_settings
  end

  # ### Value getter helpers  
  def get_configuration_settings_event(event)
    settings = @configuration.settings.with_indifferent_access
    events   = settings[:action_submit_server]
    return false unless events.present? && events.kind_of?(Array)
    events.select { |e| e[:event] == event}
  end

  def get_configuration_settings_value(*dig_path)
    # Get from the actual existing settings, usually used when the particular setting is locked by a componentable.
    @configuration.settings.with_indifferent_access.dig(dig_path)
  end

  def get_params_configuration_value(key)
    # Get the value from the params with sane defaults.  Usually called when the settings is manipulatable via the UI and not locked.
    # Used to correctly default in the 'false' case (cannot do @params_configuration[key] || true, since false will not catch).
    value = @params_configuration[key]
    case key
    when :configuration_validate
      value = true if value == nil
    when :submit_visible
      value = true if value == nil
    when :max_score
      value = 0 unless value.present?
      value = value.to_i
    when :submit_text
      value = 'Submit' unless value.present?
    end
    value
  end

end; end; end; end; end
