module Thinkspace
  module Casespace
    module Api
      class PhaseTemplatesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_serializer_options

        def show
          controller_render(@phase_template)
        end

        def select
          @phase_templates = @phase_templates.where(id: params[:ids])
          controller_render(@phase_templates)
        end
        
      end
    end
  end
end
