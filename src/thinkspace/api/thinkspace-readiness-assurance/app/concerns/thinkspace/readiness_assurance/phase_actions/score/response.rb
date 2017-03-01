module Thinkspace; module ReadinessAssurance; module PhaseActions; module Score; class Response

  attr_reader :processor, :ownerable, :config

  def initialize(processor, ownerable, config)
    @processor = processor
    @ownerable = ownerable
    @config    = config
  end

  def process; questions.process; end

  private

  include ::Thinkspace::ReadinessAssurance::PhaseActions::Helpers::Score::Base

end; end; end; end; end
