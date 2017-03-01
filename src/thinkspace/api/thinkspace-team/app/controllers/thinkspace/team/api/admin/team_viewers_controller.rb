module Thinkspace
  module Team
    module Api
      module Admin
        class TeamViewersController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_authorize! module: :action_authorize_teams

          def create
            serializer_options.remove_association :viewerable
            controller_save_record(@team_viewer)
          end

          def destroy
            controller_destroy_record(@team_viewer)
          end

        end
      end
    end
  end
end
