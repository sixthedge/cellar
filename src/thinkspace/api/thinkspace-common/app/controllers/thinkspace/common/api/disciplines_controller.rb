module Thinkspace
  module Common
    module Api
      class DisciplinesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_serializer_options

        def show
          controller_render(@discipline)
        end

        def index
          controller_render(@disciplines)
        end

        def select
          @disciplines = @disciplines.where(id: params[:ids])
          controller_render(@disciplines)
        end

      end
    end
  end
end