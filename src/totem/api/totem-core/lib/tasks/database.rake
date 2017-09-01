require File.expand_path('../totem_helper_module', __FILE__) 

namespace :totem do

  db_namespace = namespace :db do
    ENV['TOTEM_STARTUP_NO_SERIALIZERS'] = 'true'

    # convenience tasks: e.g. rake totem:db:install
    desc "Short for totem:db:install:all"
    task :install => ['totem:db:install:all']

    desc "Short for totem:db:migrate:all"
    task :migrate => ['totem:db:migrate:all']

    desc "Short for totem:db:seed:all"
    task :seed    => ['totem:db:seed:all']

    desc "Reset database"
    task :reset, [:test_data_seed_name] => [:environment] do |t, args|
      ENV['TOTEM_TEST_DATA_SEED_NAME'] = args.test_data_seed_name || ''
      unless Rails.env.test?
        # db_namespace['clobber_db'].invoke
        db_namespace['install:all'].invoke
        db_namespace['migrate:all'].invoke
      end
      Rake::Task['db:reset'].invoke
      db_namespace['domain:load'].invoke  # load the domain models after the db:reset
      db_namespace['seed:all'].invoke
    end

    desc "Soft reset database"
    task :soft_reset, [:test_data_seed_name] => [:environment] do |t, args|
      ENV['TOTEM_TEST_DATA_SEED_NAME'] = args.test_data_seed_name || ''
      unless Rails.env.test?
        db_namespace['clobber_db'].invoke
        db_namespace['install:all'].invoke
      end
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      db_namespace['migrate:all'].invoke unless Rails.env.test?
      db_namespace['seed:all'].invoke
    end

    desc "Migrate the production database"
    task :production_migrate => [:environment] do
      db_namespace['migrate:all'].invoke
    end

    desc "Seed the production database"
    task :production_seed => [:environment] do
      db_namespace['seed:all'].invoke
    end

    desc "Hard reset the production database"
    task :production_hard_reset => [:environment] do
      db_namespace[:production_migrate].invoke
      db_namespace[:production_seed].invoke
    end

    desc "Clobber db directory"
    task :clobber_db => [:environment] do
      if Rails.env.development? && ( db = File.join(Rails.root, 'db') ) && Dir.exist?(db)
        include TotemHelperModule
        totem_message "\nRemoving and Creating Path=#{db.inspect}"
        FileUtils.remove_dir(db)
        FileUtils.mkpath(db)
      end
    end

    desc "Syncs the schema_migrations table with the current pending migrations"
    task :sync_schema_migrations => [:environment] do
      pending_migrations = ActiveRecord::Migrator.open(ActiveRecord::Migrator.migrations_paths).pending_migrations

      if pending_migrations.any?
        pending_migrations.each do |pending_migration|
          version    = pending_migration.version
          table_name = 'schema_migrations'
          sql        = "INSERT INTO #{table_name} (version) VALUES (#{version});"
          puts "Executing SQL: #{sql}"
          ActiveRecord::Base.connection.execute(sql)

        end
      end
    end

    install_namespace = namespace :install do

      # Internally used task
      task :install_engine_migrations, [:engine] => [] do |t, args|
        include TotemHelperModule
        raise "Install engine is blank."  if args.engine.blank?
        name = totem_engine_name(args.engine)
        if totem_has_migration_folder?(args.engine)
          totem_message "\nInstalling migrations for engine [#{name}]."
          Rake::Task["#{name}:install:migrations"].invoke
          Rake::Task['railties:install:migrations'].reenable
        else
          totem_message "\nSkipping migration install for engine [#{name}] (no db/migrate folder)."
        end            
      end

      desc "Install ALL Totem engine migration files into rails_root/db/migrations"
      task :all => [:environment] do
        include TotemHelperModule
        totem_engines.each do |engine|
          install_namespace[:install_engine_migrations].invoke(engine)
          install_namespace[:install_engine_migrations].reenable
        end
      end

      desc "Install ONE Totem platform migration files into rails_root/db/migrations"
      task :platform, [:name] => [:environment] do |t, args|
        include TotemHelperModule
        totem_engines_by_starts_with(args.name).each do |engine|
          install_namespace[:install_engine_migrations].invoke(engine)
        end
      end

      desc "Install a Totem engine's migration files into rails_root/db/migrations e.g. rake totem:db:install:engine[totem_core]"
      task :engine, [:name] => [:environment] do |t, args|
        include TotemHelperModule
        engine = totem_engine_by_name(args.name)
        install_namespace[:install_engine_migrations].invoke(engine)
      end

    end

    migrate_namespace = namespace :migrate do

      desc "Migrate ALL Totem engine migrations"
      task :all => [:environment] do
        include TotemHelperModule
        totem_message "\nRunning rake db:migrate."
        Rake::Task['db:migrate'].invoke
      end

      # Migrate depends on ENV variables, so need to run from terminal with the appropriate ENV options.
      # ## To migrate only an engine, from console do (or can use native rake command):
      #  rake totem:db:install:engine[platform_wips_casespace]
      #  rake SCOPE='platform_wips_casespase' db:migrate

      # Optionally, could only install the engine's migrations then run totem:db:migrate.  For example:
      #  rake totem:db:install:engine[totem_authentication]
      #  rake totem:db:migrate

    end

    seed_namespace = namespace :seed do

      # Internally used task
      task :load_engine_seeds, [:name, :order] => [] do |t, args|
        include TotemHelperModule
        raise "Load engine name is blank."  if args.name.blank?
        engine = totem_engine_by_name(args.name)
        totem_message "Processing seeds for engine [#{totem_engine_name(engine)}] with seed order [#{args.order}]."
        rc = engine.load_seed
        if rc.blank?
          totem_message "--No seed file found for engine [#{totem_engine_name(engine)}]."
          totem_message ''
        end
      end

      desc "Load ALL Totem engine seeds"
      task :all => [:environment] do
        include TotemHelperModule
        totem_print_seed_order_all
        ActiveRecord::Base.transaction do
          totem_seed_order_all.each_with_index do |name, index|
            seed_namespace[:load_engine_seeds].invoke(name, index+1)
            seed_namespace[:load_engine_seeds].reenable
          end
        end
      end

      desc "Load ONE Totem platform seeds e.g. rake totem:db:seed:platform[platform-name]"
      task :platform, [:name] => [:environment] do |t, args|
        include TotemHelperModule
        app_seed_order = totem_seed_order(args.name)
        totem_print_seed_order(app_seed_order)
        ActiveRecord::Base.transaction do
          app_seed_order.each_with_index do |name, index|
            seed_namespace[:load_engine_seeds].invoke(name, index+1)
            seed_namespace[:load_engine_seeds].reenable
          end
        end
      end


      desc "Load ONE Totem engine seeds e.g. rake totem:db:seed:engine[totem_authentication]"
      task :engine, [:name, :test_data_seed_name] => [:environment] do |t, args|
        ENV['TOTEM_TEST_DATA_SEED_NAME'] = args.test_data_seed_name || ''
        include TotemHelperModule
        ActiveRecord::Base.transaction do
          seed_namespace[:load_engine_seeds].invoke(args.name)
        end
      end

    end

  end

end
