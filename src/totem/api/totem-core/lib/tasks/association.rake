require File.expand_path('../totem_helper_module', __FILE__) 

namespace :totem do

  namespace :association do

    # Use:
    # rake TASKNAME='association:list'      totem:association:list  #=> print clean log
    # rake TASKNAME='association:list:full' totem:association:list  #=> print detailed log entries
    # rake TASKNAME='association:list' LIST='Platform::Wips::Casespace::Assignment, Platform::Wips::Casespace::Phase, ...' totem:association:list"
    # rake TASKNAME='association:list' LIKE='Platform::Wips, Totem, ...' totem:association:list"
    desc "List associations added by 'totem_association' - rake TASKNAME='association:list' totem:association:list"
    task :list, [] => [:environment] do |t, args|
      include TotemHelperModule
      totem_eager_load
      totem_output_association_warnings
    end

    desc "Print the combined model definition yaml file on the console - rake totem:association:yaml"
    task :yaml, [] => [:environment] do |t, args|
      include Totem::Core::Models::Definitions
      model_definitions = get_model_definitions
      if model_definitions.present?
        puts model_definitions.to_yaml
      else
        puts "No model definition files to print"
      end
    end

  end

end
