module Thinkspace
  module Team
    module Api
      module Admin
        class TeamTeamablesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_authorize! module: :action_authorize_teams

          def create
            serializer_options.remove_association :teamable
            controller_save_record(@team_teamable)
          end

          def destroy
            controller_destroy_record(@team_teamable)
          end

        end
      end
    end
  end
end
