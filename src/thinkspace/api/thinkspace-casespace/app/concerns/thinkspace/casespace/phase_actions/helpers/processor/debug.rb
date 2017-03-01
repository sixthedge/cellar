module Thinkspace; module Casespace; module PhaseActions; module Helpers; module Processor; module Debug

  def debug?; @debug == true; end

  def debug(message, ownerable=nil, phase=current_phase)
    message += debug_ownerable(ownerable)  if ownerable.present?
    message += debug_phase(phase)
    name     = self.class.name.demodulize
    puts '[debug] ' + "#{name} -> " + message
  end

  private

  def debug_phase(phase=current_phase)
    " for phase [id: #{phase.id}, title: #{phase.title.inspect}]."
  end

  def debug_ownerable(ownerable)
    type = ownerable.class.name.demodulize.downcase
    " for #{type.inspect} ownerable [id: #{ownerable.id}, title: #{ownerable.title.inspect}]"
  end

end; end; end; end; end; end
