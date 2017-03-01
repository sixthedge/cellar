module Thinkspace
  module Casespace
    module Api
      class AssignmentTypesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_serializer_options

        def index
          controller_render(@assignment_types)
        end

        def show
          controller_render(@assignment_type)
        end

        def select
          @assignment_types = @assignment_types.where(id: params[:ids])
          controller_render(@assignment_types)
        end
        
      end
    end
  end
end
