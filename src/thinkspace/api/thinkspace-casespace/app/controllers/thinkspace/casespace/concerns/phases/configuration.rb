module Thinkspace; module Casespace; module Concerns; module Phases; module Configuration

  # # Entry
  def update_phase_configuration
    # Load configuration hash from params.
    return unless params_root.has_key?(:configuration)
    return unless params_root[:configuration].present?
    @configuration = params_root[:configuration]
    set_all_phase_settings
  end

  def set_all_phase_settings
    set_validation
    set_phase_score
    set_submit
  end

  # # Configuration setters
  # ## Validation
  def set_validation
    return unless has_builder_ability_and_param?(:configuration_validate)
    @phase.settings[:validation] ||= Hash.new
    @phase.settings[:validation][:validate] ||= Hash.new
    @phase.settings[:validation][:validate] = @configuration[:configuration_validate] || true
  end

  # ## Phase Score
  def set_phase_score
    return unless has_builder_ability_and_param?(:max_score)
    @phase.settings[:phase_score_validation] ||= Hash.new
    @phase.settings[:phase_score_validation][:numericality] ||= Hash.new
    @phase.settings[:phase_score_validation][:numericality][:less_than_or_equal_to] = @configuration[:max_score].to_f || 0.0
  end

  # ## Submit button
  def set_submit
    return unless has_configuration_param?(:submit_visible) || has_configuration_param?(:submit_text)
    @phase.settings[:submit] ||= Hash.new
    set_submit_visible
    set_submit_text
  end

  def set_submit_visible
    @phase.settings[:submit][:visible] = @configuration[:submit_visible] || true
  end

  def set_submit_text
    @phase.settings[:submit][:text] = @configuration[:submit_text] || 'Submit'
  end

  # # Helpers
  def has_builder_ability?(key); @builder_abilities[key]; end
  def has_configuration_param?(key); @configuration.has_key?(key) && @configuration[key].present?; end
  def has_builder_ability_and_param?(key); has_builder_ability?(key) && has_configuration_param?(key); end

end; end; end; end; end
