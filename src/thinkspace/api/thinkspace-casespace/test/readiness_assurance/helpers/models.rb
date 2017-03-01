module Test::ReadinessAssurance::Helpers::Models
extend ActiveSupport::Concern
included do

  def pubsub; @pubsub ||= server_event_class.totem_pubsub; end

  def irat_phase; get_phase(:ra_irat_phase_test); end
  def trat_phase; get_phase(:ra_trat_phase_test); end

  def phase_submit_unlock_next(phase=current_phase)
    settings, submit = get_phase_submit_settings(phase)
    submit[:unlock]  = :next
    save_phase_settings(phase, settings)
  end

  def phase_submit_unlock_next_after_all_ownerables(phase=current_phase)
    settings, submit = get_phase_submit_settings(phase)
    submit[:unlock]  = :next_after_all_ownerables
    save_phase_settings(phase, settings)
  end

  def get_phase_submit_settings(phase=current_phase)
    settings = (phase.settings || Hash.new).deep_symbolize_keys
    actions  = (settings[:actions] ||= Hash.new)
    submit   = (actions[:submit] ||= Hash.new)
    [settings, submit]
  end

  def save_phase_settings(phase, settings)
    phase.settings = settings
    raise "Phase record #{phase.inspect} could not be saved." unless phase.save
  end

  def get_assignment; irat_phase.thinkspace_casespace_assignment; end

  def get_assessment
    authable.thinkspace_casespace_phase_components.where(componentable_type: assessment_class.name).first.componentable
  end

  def get_server_events(options={})
    options[:authable] ||= authable
    server_event_class.where(options)
  end

  def get_response(ro=nil)
    ro ||= get_let_value(:response_ownerable) || ownerable
    assessment.thinkspace_readiness_assurance_responses.find_by(ownerable: ro) || assessment.find_or_create_response(ro, current_user)
  end

  def get_timetable(timeable, ownerable=nil)
    timetable_class.find_by(timeable: timeable, ownerable: ownerable)
  end

  def unlock_authable; authable.activate; authable.default_state = 'unlocked'; authable.save; end

  def assessment_class;   Thinkspace::ReadinessAssurance::Assessment; end
  def timetable_class;    Thinkspace::Common::Timetable; end
  def server_event_class; Thinkspace::PubSub::ServerEvent; end

  def print_timetables
    print_test_name
    puts "\n---------------------Timetables\n"
    timetable_class.all.each do |tt|
      ta  = tt.timeable
      tas = ta.class.name.demodulize
      o   = tt.ownerable
      os  = o.blank? ? "- none" : "id=#{o.id} #{o.class.name.demodulize}: #{o.title}"
      puts "\n---------------------#{tas} id=#{ta.id} #{ta.title.inspect} -> Ownerable #{os}"
      pp tt
    end
  end

  def print_server_events
    print_test_name
    puts "\n---------------------Server Events\n"
    server_event_class.all.each do |se|
      sa  = se.authable
      sas = sa.class.name.demodulize
      puts "\n---------------------#{sas} id=#{sa.id} #{sa.title.inspect} -> RoomEvent=#{se.room_event.inspect} -> Event=#{se.event.inspect}"
      pp se
    end
  end

end; end
