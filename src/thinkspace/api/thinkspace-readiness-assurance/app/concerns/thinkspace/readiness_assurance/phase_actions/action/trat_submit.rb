module Thinkspace; module ReadinessAssurance; module PhaseActions; module Action
class TratSubmit < Thinkspace::Casespace::PhaseActions::Action::Submit

  attr_reader :irat_phase, :trat_phase

  def process
    super
  end

  private

  include Helpers::Handler::Classes

end; end; end; end; end
