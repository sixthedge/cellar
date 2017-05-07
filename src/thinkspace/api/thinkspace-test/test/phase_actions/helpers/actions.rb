module Test::PhaseActions::Helpers::Actions
extend ActiveSupport::Concern
included do

  def phase_action_processor_class; ::Thinkspace::Casespace::PhaseActions::Processor; end

  def process_action; pap.process_action(ownerable); end

  def assignment_phases
    assignment = current_phase.thinkspace_casespace_assignment
    assignment.thinkspace_casespace_phases.scope_active.order(:position)
  end

  def next_phases(phase=current_phase); assignment_phases.where('position > ?', phase.position).order(:position); end
  def prev_phases(phase=current_phase); assignment_phases.where('position < ?', phase.position).order(:position); end

  def next_phase(phase=current_phase); next_phases.first; end
  def prev_phase(phase=current_phase); prev_phases.first; end

  def clear_phase_settings(phase=current_phase); phase.settings = nil; phase.save; end

  def set_phase_settings(settings, phase=current_phase); phase.settings = settings; phase.save; end

  def update_phase_config(settings, phase=current_phase)
    clear_phase_settings(phase)
    config          = phase.thinkspace_common_configuration
    config.settings = settings
    config.save
  end

  def set_next_phase_states_state(state, phase=current_phase)
    next_phases(phase).each do |p|
      ps = p.find_or_create_state_for_ownerable(ownerable, current_user)
      ps.current_state = state
      ps.save
    end
  end

  def print_phase_states(phase=nil)
    scope = Thinkspace::Casespace::PhaseState.all.order(:phase_id)
    scope = scope.where(phase_id: phase.id)  if phase.present?
    print_test_name
    scope.each do |ps|
      p  = ps.thinkspace_casespace_phase
      o  = ps.ownerable
      s  = ps.thinkspace_casespace_phase_score
      st = s.present? ? "#{ps.score}" : 'none'
      puts "\n---------------------Phase id=#{p.id} #{p.title.inspect} -> Ownerable id=#{o.id} #{o.class.name.demodulize}: #{o.title} -> Score: #{st}"
      pp ps
    end
  end

  def print_phase_scores
    print_test_name
    Thinkspace::Casespace::PhaseScore.all.order(:phase_state_id).each do |ps|
      puts "\n**Phase score for id [#{ps.id}]: #{ps.score}\n"
      pp ps
    end
  end

  def print_test_name
    len = 130
    puts "\n"
    puts '-' * len
    puts "-----Test: #{self.class.name} -> #{name}".ljust(len,'-')
    puts '-' * len
  end

end; end
