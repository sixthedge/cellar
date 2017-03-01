# Examples:
# rake totem:db:domain:create #=> create domain_data folder and domain yml files all engines
# rake totem:db:domain:create[thinkspace*] #=> all thinkspace engines
# rake totem:db:domain:create[thinkspace_common] #=> thinkspace_common engine only (engine_name not engine/path)
# rake totem:db:domain:load[thinkspace*] #=> all thinkspace engines domain models
# rake totem:db:domain:load[thinkspace_common] #=> thinkspace_common all domain model
# rake totem:db:domain:load[thinkspace_common,components] #=> thinkspace_common components model only

namespace :totem do

  db_namespace = namespace :db do

    domain_namespace = namespace :domain do
 
      task :create, [] => [:environment] do |t, args|
        domain_namespace['totem_db_domain_class'].invoke
        @totem_db_domain_class.new.create_files args.extras
      end

      task :load, [] => [:environment] do |t, args|
        domain_namespace['totem_db_domain_class'].invoke
        @totem_db_domain_class.new.load_files args.extras
      end

      task :compare, [] => [:environment] do |t, args|
        domain_namespace['totem_db_domain_class'].invoke
        @totem_db_domain_class.new.compare_files args.extras
      end

      task :load_from_yml, [] => [:environment] do |t, args|
        domain_namespace['totem_db_domain_class'].invoke
        @totem_db_domain_class.new.load_from_yml args.extras
      end

      task :totem_db_domain_class do |t, args|
        @totem_db_domain_class ||= Totem::Core::Database::Domain::Loader
      end

    end

  end

end
