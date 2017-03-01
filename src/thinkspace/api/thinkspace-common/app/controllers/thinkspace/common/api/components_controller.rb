module Thinkspace
  module Common
    module Api
      class ComponentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_serializer_options

        def index
          controller_render(@components)
        end

        def show
          controller_render(@component)
        end

        def select
          @components = @components.where(id: params[:ids])
          controller_render(@components)
        end

      end
    end
  end
end
