module Thinkspace
  module Common
    module Api
      class SpacesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_serializer_options

        def index
          controller_render(@spaces)
        end

        # Called via url for a specific assignment e.g. casespace/assignments/1.
        def show
          controller_render(@space)
        end

      end
    end
  end
end
