module Totem
  module Core
    module Controllers
      module TotemControllerModelClass

        extend ActiveSupport::Concern
        
        module ClassMethods

          # ######################################################################################
          # @!group Class method to return the controller's class name.
          # (e.g. used by load_and_authorize class: totem_controller_model_class)

          def totem_controller_model_class
            klass = self.controller_path.classify
            name  = klass.demodulize.sub(/Controller$/,'').singularize
            # klass = klass.deconstantize.sub(/::Api$/,'')
            klass = klass.deconstantize.sub(/::Api/,'')
            klass = klass.sub(/::Admin/, '')
            klass = "#{klass}::#{name}"
          end

        end

      end
    end
  end
end