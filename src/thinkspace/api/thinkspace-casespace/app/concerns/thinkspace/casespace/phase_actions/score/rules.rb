module Thinkspace; module Casespace; module PhaseActions; module Score; class Rules

  attr_reader :processor, :ownerable, :config

  def initialize(processor, ownerable, config)
    @processor = processor
    @ownerable = ownerable
    @config    = config
  end

  def process; get_score; end

  private

  def get_score
    raise "Phase actions score with class 'rules' not implemented"
  end

end; end; end; end; end
