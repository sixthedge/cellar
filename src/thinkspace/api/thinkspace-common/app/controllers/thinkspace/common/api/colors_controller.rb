module Thinkspace
  module Common
    module Api
      class ColorsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_serializer_options

        def show
          controller_render(@color)
        end

        def index
          controller_render(@colors)
        end

        def select
          @colors = @colors.where(id: params[:ids])
          controller_render(@colors)
        end

      end
    end
  end
end