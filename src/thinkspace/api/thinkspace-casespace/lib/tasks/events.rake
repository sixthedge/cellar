namespace :thinkspace do
  namespace :events do

    task :set_auto_score_for_assignment, [:assignment_id] => [:environment] do |t, args|
      assignment_id = args.assignment_id
      assignment    = Thinkspace::Casespace::Assignment.find(assignment_id)
      phases        = assignment.thinkspace_casespace_phases
      phases.each do |phase|
        config          = phase.get_configuration
        settings        = config.settings
        submit_settings = settings['action_submit_server']
        submit_settings = Array.wrap(submit_settings)
        submit_keys     = submit_settings.map { |h| h['event'] } if submit_settings.present?
        has_event       = submit_keys.include?(:auto_score) || false

        if has_event
          auto_score_events = submit_settings.select { |h| h['event'] == :auto_score }
          puts "[auto_score_for_assignment] WARN: Skipping phase ID: #{phase.id} due to more than one auto_score event." if auto_score_events.length > 1
          submit_settings.each do |setting|
            next if setting['event'] != :auto_score
            setting['phase_id']       = phase.id
          end
        else
          auto_score_event = {event: :auto_score, phase_id: phase.id}
        end

        config.settings['action_submit_server'] = submit_settings
        config.save
        puts "[auto_score_for_assignment] Phase ID: #{phase.id} now has configuration of: #{config.inspect}"
      end
    end

    task :set_complete_phase_for_assignment, [:assignment_id] => [:environment] do |t, args|
      assignment_id = args.assignment_id
      assignment    = Thinkspace::Casespace::Assignment.find(assignment_id)
      phases        = assignment.thinkspace_casespace_phases
      phases.each do |phase|
        config          = phase.get_configuration
        settings        = config.settings
        submit_settings = settings['action_submit_server']
        submit_settings = Array.wrap(submit_settings)
        submit_keys     = submit_settings.map { |h| h['event'] } if submit_settings.present?
        has_event       = submit_keys.include?(:complete_phase) || false

        if has_event
          complete_phase = submit_settings.select { |h| h['event'] == :complete_phase }
          puts "[complete_phase_for_assignment] WARN: Skipping phase ID: #{phase.id} due to more than one complete_phase event." if complete_phase.length > 1
          submit_settings.each do |setting|
            next if setting['event'] != :complete_phase
            setting['phase_id'] = phase.id
          end
        else
          complete_event = {event: :complete_phase, phase_id: phase.id}
          submit_settings.push complete_event
        end

        config.settings['action_submit_server'] = submit_settings
        config.save
        puts "[complete_phase_for_assignment] Phase ID: #{phase.id} now has configuration of: #{config.inspect}"
      end
    end

    task :set_unlock_phase_for_assignment, [:assignment_id] => [:environment] do |t, args|
      event_name    = :unlock_phase
      assignment_id = args.assignment_id
      assignment    = Thinkspace::Casespace::Assignment.find(assignment_id)
      phases        = assignment.thinkspace_casespace_phases.order('position')
      phases.each_with_index do |phase, i|
        config          = phase.get_configuration
        settings        = config.settings
        submit_settings = settings['action_submit_server']
        submit_settings = Array.wrap(submit_settings)
        submit_keys     = submit_settings.map { |h| h['event'] } if submit_settings.present?
        has_event       = submit_keys.include?(event_name) || false
        next_phase      = phases[i + 1]
        puts "[unlock_phase_for_assignment] Skipping phase ID: #{phase.id} because it is the last phase, cannot unlock." if not next_phase
        next            if not next_phase


        if has_event
          event  = submit_settings.select { |h| h['event'] == event_name }
          puts "[unlock_phase_for_assignment] WARN: Skipping phase ID: #{phase.id} due to more than one complete_phase event." if event.length > 1
          submit_settings.each do |setting|
            next if setting['event'] != event_name
            setting['phase_id'] = next_phase.id
          end
        else
          event = {event: event_name, phase_id: next_phase.id}
          submit_settings.push event
        end

        config.settings['action_submit_server'] = submit_settings
        config.save
        puts "[unlock_phase_for_assignment] Phase ID: #{phase.id} now has configuration of: #{config.inspect}"
      end
    end

    task :convert_action_submit_server_events_format, [] => [:environment] do |t, args|
      # Goal is to convert things with explicit phase_ids to relative identifiers, such as:
      # => :next, :previous, :self, :next + 5, etc.
      # => {event: :unlock_phase, phase_id: 5} to {event: :unlock_phase, phase_id: :next}
      Thinkspace::Casespace::Assignment.all.each do |a|
        phases = a.thinkspace_casespace_phases.order('position')
        phases.each_with_index do |p, i|
          configuration = p.get_configuration
          next unless configuration
          settings = configuration.settings
          events   = Array.wrap(settings['action_submit_server'])
          next if not events or events.empty?
          submit_events = []
          events.each do |event|
            phase_id          = event['phase_id']
            event['phase_id'] = :self if phase_id == p.id
            event['phase_id'] = :next if phases[i + 1].present? and phase_id == phases[i + 1].id
            event['phase_id'] = :previous if phases[i - 1].present? and phase_id == phases[i - 1].id
            submit_events.push event
          end
          events = submit_events
          puts "[convert_assef] Saving configuration of: \n #{configuration.inspect} \n" if configuration.save
        end
      end
    end

    task :action_submit_server_events_report, [] => [:environment] do |t, args|
      Thinkspace::Casespace::Assignment.all.each do |a|
        a.thinkspace_casespace_phases.order('position').each do |p|
          configuration = p.get_configuration
          next unless configuration
          events = Array.wrap(configuration.settings['action_submit_server'])
          puts "\n Phase [#{p.id}] [#{p.title}] [#{p.thinkspace_casespace_assignment.title}] events: \n"
          events.each do |event|
            puts "#{event.inspect} \n"
          end
        end
      end

    end
  end
end
