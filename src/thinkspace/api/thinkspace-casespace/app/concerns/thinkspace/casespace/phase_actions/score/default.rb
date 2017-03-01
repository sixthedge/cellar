module Thinkspace; module Casespace; module PhaseActions; module Score; class Default

  attr_reader :processor, :ownerable, :config

  def initialize(processor, ownerable, config)
    @processor = processor
    @ownerable = ownerable
    @config    = config
  end

  def process; get_score; end

  private

  def get_score
    case
    when config.is_a?(Hash)
      get_score_from_config
    else
      get_score_from_validation_settings
    end
  end

  def get_score_from_config
    min = config[:min] || 1
    max = config[:max] || 1
    max  # currently returning max score until additional auto score rules implemented
  end

  def get_score_from_validation_settings
    settings = processor.get_phase_settings
    min      = settings.dig(:phase_score_validation, :numericality, :greater_than_or_equal_to) || 1
    max      = settings.dig(:phase_score_validation, :numericality, :less_than_or_equal_to) || 1
    max  # currently returning max score until additional auto score rules implemented
  end

end; end; end; end; end
