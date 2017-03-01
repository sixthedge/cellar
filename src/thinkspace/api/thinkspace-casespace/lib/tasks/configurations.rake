namespace :thinkspace do
  namespace :configurations do
    task :convert_all_to_common, [] => [:environment] do |t, args|
      Thinkspace::Casespace::Configuration.all.each do |c|
        existing = Thinkspace::Common::Configuration.find_by(configurable: c.configurable)
        next if existing.present?
        new_config                   = Thinkspace::Common::Configuration.new
        new_config.configurable_type = c.configurable_type
        new_config.configurable_id   = c.configurable_id
        new_config.settings          = c.settings
        if new_config.save
          puts "\n [convert_all_to_common] Porting Casespace::Configuration id [#{c.id}] to: "
          puts "\n #{new_config.inspect}"
        end
      end
    end

    task :reset_phase_settings, [] => [:environment] do |t, args|
      phases = Thinkspace::Casespace::Phase.all
      phases.each do |phase|
        phase.settings = Hash.new
        puts "\n Saving phase ID: #{phase.id} \n"
        phase.save
      end
    end

    task :convert_configurations_to_phase_settings, [] => [:environment] do |t, args|
      phases = Thinkspace::Casespace::Phase.all
      user   = Thinkspace::Common::User.first # Used in processor.
      phases.each do |phase|
        puts "Processing Phase [#{phase.id}].....\n"
        config          = phase.get_configuration
        settings        = config.settings.with_indifferent_access
        processor       = Thinkspace::Casespace::PhaseActions::Processor.new(phase, user, {action: :submit})
        submit_settings = processor.action_settings

        settings[:actions] = Hash.new
        settings[:actions][:submit] = submit_settings
        settings.delete(:action_submit_server)
        phase.settings = settings
        if phase.save
          puts "Phase saved successfully with settings of: \n"
          puts settings.inspect
          puts "\nPorted from: \n"
          puts config.settings.inspect
          puts "\n\n"
        else
          puts "\n\nERROR SAVING PHASE #{phase.id}\n\n"
        end
      end

    end
  end
end