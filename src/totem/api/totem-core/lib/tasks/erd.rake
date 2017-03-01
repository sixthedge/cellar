require File.expand_path('../totem_helper_module', __FILE__) 

namespace :totem do

  db_namespace = namespace :erd do

    desc "Totem ERD"
    task :all, [] => [:environment] do |t, args|
      require 'rails_erd/diagram/graphviz'
      include TotemHelperModule
      totem_eager_load
      options            = totem_erd_options
      options[:title]    = 'Totem ERD'
      options[:filename] = totem_erb_filename_location('erd_totem_all')
      RailsERD::Diagram::Graphviz.create(options)
    end

    # Selects the model classes if they start with the classified name provided.
    # Example: rake totem:erd:only[Platform::Wips] matches all model classes starting with Platform::Wips
    #          rake totem:erd:only[Platform] matches all model classes starting with Platform
    desc "Totem ERD Only e.g. rake totem:erd:only[platform/wips]"
    task :only, [:name] => [:environment] do |t, args|
      require 'rails_erd/diagram/graphviz'
      include TotemHelperModule
      totem_eager_load
      name                   = args.name || ''
      options                = totem_erd_options
      options[:title]        = "#{name} ERD"
      options[:filename]     = totem_erb_filename_location("erd_#{name.underscore.gsub('/','_')}")
      options[:polymorphism] = false  if name.downcase == totem_framework_name
      selected_classes       = totem_erb_select_models(name)
      if selected_classes.present?
        RailsERD.options.only = selected_classes
        RailsERD::Diagram::Graphviz.create(options)
      else
        puts "[error] No model classes match [#{args.name}]"
      end
    end

  end

end
