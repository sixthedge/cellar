require File.expand_path('../totem_helper_module', __FILE__) 

namespace :totem do
  namespace :jobs do
    task :work, [] => [:environment] do |t, args|
      include TotemHelperModule
      totem_eager_load
      Rake::Task['jobs:work'].invoke
    end
  end
end