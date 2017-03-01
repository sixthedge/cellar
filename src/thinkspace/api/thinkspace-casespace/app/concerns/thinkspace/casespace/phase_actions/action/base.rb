module Thinkspace; module Casespace; module PhaseActions; module Action; class Base

  attr_reader :processor, :ownerable, :current_user

  def initialize(processor, ownerable)
    @processor    = processor
    @ownerable    = ownerable
    @current_user = processor.current_user
  end

  # Should be overridden by an extending class.
  def process
    post_process
  end

  # Can be overridden by an extending class.
  def post_process; end

  private

  include Helpers::Action::Controller

end; end; end; end; end
