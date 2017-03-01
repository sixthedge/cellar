namespace :thinkspace do

  phase_template_namespace = namespace :phase_template do

    task :create, [] => [:environment] do |t, args|
      phase_template_namespace['set_phase_template_class'].invoke
      @phase_template_class.new.process(args.extras)
    end

    task :set_phase_template_class do |t, args|
      @phase_template_class ||= Thinkspace::Casespace::CaseManager::PhaseTemplate
    end

  end

end
