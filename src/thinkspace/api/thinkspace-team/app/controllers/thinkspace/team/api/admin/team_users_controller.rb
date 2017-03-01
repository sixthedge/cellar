module Thinkspace
  module Team
    module Api
      module Admin
        class TeamUsersController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_authorize! module: :action_authorize_teams

          def create
            serializer_options.authorize_action :view, :thinkspace_common_user
            controller_save_record(@team_user)
          end

          def destroy
            controller_destroy_record(@team_user)
          end

        end
      end
    end
  end
end
