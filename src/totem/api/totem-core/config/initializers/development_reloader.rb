if ::Rails.env.development?

  quiet = ::Totem::Settings.config.startup_quiet?

  ::Rails.application.config.after_initialize do |app|

    # Watches for changes to an association.yml file then clears the classes so totem_associations are reloaded.
    # If 'rails console', need to do reload!
    files = ::Totem::Settings.engine.association_paths.dup
    puts "[debug] Watching #{files.length} association.yml files for changes"  unless quiet

    associations_yml_reloader = ::ActiveSupport::FileUpdateChecker.new(files) do
      puts "[debug] An associations.yml file has changed and the associations are reset."  unless quiet
      ::Totem::Settings.associations.reset! # Reset totem associations.yml definitions to re-load the associations.yml files.
      ::ActiveSupport::Dependencies.clear   # Clear all loaded classes so will be reloaded (even if not changed) and totem_associations re-called.
    end

    ::ActiveSupport::Reloader.to_prepare do
      associations_yml_reloader.execute_if_updated
    end

    app.reloaders << associations_yml_reloader

    # Watches for changes to an platform's ability class files then clears the classes so the Ability class is reloaded.
    # if 'rails console', need to do reload!
    ability_pattern = Rails.root.join('config/totem/ability_files/**/*.rb').to_s
    ability_files   = Dir.glob(ability_pattern)
    if ability_files.blank?
      puts "[debug] WARNING no ability files found with pattern #{ability_pattern}."
    else
      puts "[debug] Watching #{ability_files.length} ability files for changes"

      abilities_reloader = ::ActiveSupport::FileUpdateChecker.new(ability_files) do
        puts "[debug] An abilities class file has changed and classes reloaded."  unless quiet
        ::ActiveSupport::Dependencies.clear   # Clear all loaded classes so will be reloaded (even if not changed).
      end

      ::ActionDispatch::Reloader.to_prepare do
        abilities_reloader.execute_if_updated
      end

      app.reloaders << abilities_reloader

    end

  end

end
