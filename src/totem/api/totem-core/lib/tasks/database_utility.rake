# Examples:
# rake totem:db:inspect:print[help]

namespace :totem do

  db_namespace = namespace :db do

    domain_namespace = namespace :inspect do
 
      task :print, [] => [:environment] do |t, args|
        Totem::Core::Database::Inspect::PrintModel.new.process args.extras
      end

    end

  end

end
