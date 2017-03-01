module Thinkspace
  module Casespace
    module Api
      class PhaseComponentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_serializer_options

        def show
          controller_render(@phase_component)
        end

        def select
          @phase_components = @phase_components.where(id: params[:ids])
          controller_render(@phase_components)
        end

      end
    end
  end
end
