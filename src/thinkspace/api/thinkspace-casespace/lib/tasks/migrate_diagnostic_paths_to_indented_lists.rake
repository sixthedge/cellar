namespace :thinkspace do

  migrate_namespace = namespace :migrate do

    task_namespace = namespace :diagnostic_paths_to_indented_lists do

      task :spaces      do |t, args|; task_namespace[:do_process_method].invoke(:process_spaces,      args.extras); end
      task :assignments do |t, args|; task_namespace[:do_process_method].invoke(:process_assignments, args.extras); end
      task :phases      do |t, args|; task_namespace[:do_process_method].invoke(:process_phases,      args.extras); end
      task :paths       do |t, args|; task_namespace[:do_process_method].invoke(:process_paths,       args.extras); end
      task :all         do |t, args|; task_namespace[:do_process_method].invoke(:process_all,         args.extras); end

      # ### Helper Tasks.

      task :do_process_method, [:call_method] do |t, args|
        task_namespace[:startup_quiet].invoke
        task_namespace[:require_file].invoke
        task_namespace[:call_process_method].invoke(args.call_method, args.extras)
      end

      task :startup_quiet, [] => [] do; ENV['TOTEM_STARTUP_QUIET'] = 'true'; end

      task :require_file, [] do |t, args|
        spec    = Gem::Specification.find_by_path('thinkspace')
        gem_dir = spec.gem_dir
        file    = File.join(gem_dir, 'migrate', 'diagnostic_paths_to_indented_lists', 'process.rb')
        task_namespace[:stop_run].invoke("File #{file.inspect} does not exist.")  unless File.file?(file)
        require file
      end

      task :call_process_method, [:call_method] => [:environment] do |t, args|
        method     = args.call_method
        class_name = 'Thinkspace::Migrate::DiagnosticPathsToIndentedLists::Process'
        task_namespace[:stop_run].invoke("Process method is blank for #{class_name.inspect}.")  if method.blank?
        klass = class_name.safe_constantize
        task_namespace[:stop_run].invoke("Class #{class_name.inspect} cannot be constantized.")  if klass.blank?
        klass.new.process(method, args.extras)
      end

      task :stop_run, [:message] do |t, args|
        message = args.message || ' '
        puts ''
        puts '-'.ljust(message.length, '-')
        puts message
        puts 'Run stopped.'
        puts '-'.ljust(message.length, '-')
        puts ''
        exit
      end


    end
  end
end
