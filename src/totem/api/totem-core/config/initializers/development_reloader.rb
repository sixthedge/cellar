if ::Rails.env.development?

  quiet = ::Totem::Settings.config.startup_quiet?

  ::Rails.application.config.after_initialize do |app|

    # Watches for changes to an association.yml file then clears the classes so totem_associations are reloaded.
    # if 'rails console', need to do reload!
    files = ::Totem::Settings.engine.association_paths.dup
    # puts "[debug] Watching for changes to association.yml files: #{files.inspect}"
    puts "[debug] Watching #{files.length} association.yml files for changes"  unless quiet

    associations_yml_reloader = ::ActiveSupport::FileUpdateChecker.new(files) do
      puts "[debug] An associations.yml file has changed and the associations are reset."  unless quiet
      ::Totem::Settings.associations.reset! # Reset totem associations.yml definitions to re-load the associations.yml files.
      ::ActiveSupport::Dependencies.clear   # Clear all loaded classes so will be reloaded (even if not changed) and totem_associations re-called.
    end

    ::ActionDispatch::Reloader.to_prepare do
      associations_yml_reloader.execute_if_updated
    end

    app.reloaders << associations_yml_reloader

    # Watches for changes to an platform's ability class file then clears the classes so the Ability class is reloaded.
    # if 'rails console', need to do reload!
    ability_path  = Rails.root.join('config', 'totem')
    ability_files = Dir.glob(File.join(ability_path, '*.abilities.yml'))
    files         = Array.new
    ability_files.each do |file|
      ability = YAML.load(File.read(file))
      classes = ability['classes']
      [classes].flatten.compact.each do |hash|
        path = hash['path']
        puts "[debug] WARNING ability class #{hash.inspect} path in #{file.inspect} is blank." if path.blank?
        next unless path.present?
        puts "[debug] WARNING ability class path #{path.inspect} in #{hash.inspect} is not a directory."  unless File.directory?(path)
        ability_files = Dir.glob File.join(path, '**/*.rb')
        ability_files.each do |file|
          files.push(file)
          relative_path = Pathname.new(file).relative_path_from(Rails.root).to_s
          puts "[debug] Watching ability class file for changes #{relative_path.inspect}"  unless quiet
        end
      end
    end

    abilities_module_reloader = ::ActiveSupport::FileUpdateChecker.new(files) do
      puts "[debug] An abilities class file has changed and classes reloaded."  unless quiet
      ::ActiveSupport::Dependencies.clear   # Clear all loaded classes so will be reloaded (even if not changed).
    end

    ::ActionDispatch::Reloader.to_prepare do
      abilities_module_reloader.execute_if_updated
    end

    app.reloaders << abilities_module_reloader

  end

end
