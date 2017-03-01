module Totem
  module Core
    module Models
      class Virtual
        include ActiveModel::Model

        def self.totem_associations(options={})
          env = options[:env] || ::Totem::Settings
          env.associations.perform(self, options)
        end
        
        def self.table_exists?
          true
        end
        
        def self.column_names
          []
        end
      end
    end
  end
end