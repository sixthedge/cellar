module Thinkspace
  module Team
    module Api
      module Admin
        class TeamSetsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_serializer_options
          totem_action_authorize! module: :action_authorize_teams
          before_action :authorize_authable, except: [:create, :select]

          def create
            space = Thinkspace::Common::Space.find_by(id: params_root['thinkspace/common/space_id'])
            authorize! :update, space
            @team_set.space_id    = params_root['thinkspace/common/space_id']
            @team_set.title       = params_root[:title]
            @team_set.description = params_root[:description]
            @team_set.default     = params_root[:default]
            controller_save_record(@team_set)
          end

          def show
            controller_render(@team_set)
          end

          def select
            # TODO: Authorize
            #@team_sets = @team_sets.where(id: params[:ids])
            controller_render(@team_sets)
          end

          def update
            raise_access_denied_exception("Cannot update a locked team set.") if @team_set.locked?
            @team_set.title = params_root[:title]
            controller_save_record(@team_set)
          end

          def teams
            controller_render_plural_root(@team_set)
          end

          def destroy
            raise_access_denied_exception("Cannot destroy a locked team set.") if @team_set.locked?
            controller_destroy_record(@team_set)
          end

          def abstract
            controller_render_json(@team_set.abstract(:users, :teams))
          end

          private

          def authorize_authable
            authorize! :update, @team_set.authable
          end
          
        end
      end
    end
  end
end
