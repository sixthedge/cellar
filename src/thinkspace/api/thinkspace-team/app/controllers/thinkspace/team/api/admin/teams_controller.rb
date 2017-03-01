module Thinkspace
  module Team
    module Api
      module Admin
        class TeamsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_authorize! module: :action_authorize_teams, params_ownerable: false
          totem_action_serializer_options

          def create
            @team.title       = (params_root[:title] || '').strip
            @team.description = params_root[:description]
            @team.color       = params_root[:color]
            @team.team_set_id = params_association_id(:team_set_id)
            process_updates
            controller_save_record(@team)
          end

          def update
            raise_access_denied_exception('Cannot update a locked team.') if @team.locked? # Do not allow updates to a locked team. # TODO: This maybe should return an error.
            raise_access_denied_exception('Cannot update a team in a locked team set.') if @team.thinkspace_team_team_set.locked?

            @team.title       = (params_root[:title] || '').strip
            @team.description = params_root[:description]
            @team.color       = params_root[:color]
            process_updates
            controller_save_record(@team)
          end

          def destroy
            raise_access_denied_exception('Cannot update a locked team.') if @team.locked? # Do not allow updates to a locked team. # TODO: This maybe should return an error.
            raise_access_denied_exception('Cannot update a team in a locked team set.') if @team.thinkspace_team_team_set.locked?

            @team.transaction do
              # First delete any team_viewer associations that can view the team to be destroyed.
              Thinkspace::Team::TeamViewer.where(viewerable: @team).each do |team_viewer|
                raise_team_exception "Cannot destroy team_viewer [#{team_viewer.inspect}]"  unless team_viewer.destroy
              end
              controller_destroy_record(@team)
            end
          end

          private

          def raise_team_exception(message='')
            raise TeamError, message
          end

          def process_updates
            updates      = params_root[:updates]
            if updates.present?
              if updates.has_key?(:users)
                user_changes = updates[:users]
                add          = user_changes[:add]
                remove       = user_changes[:remove]
                process_user_changes(:add, add) if add.present?
                process_user_changes(:remove, remove) if remove.present?
              end
            end
          end

          def process_user_changes(type, user_ids)
            case type
            when :add
              existing_ids = @team.thinkspace_common_user_ids
              ids          = existing_ids + user_ids
              ids.uniq!
              @team.thinkspace_common_user_ids = ids
            when :remove
              existing_ids = @team.thinkspace_common_user_ids
              ids          = existing_ids - user_ids
              ids.uniq!
              @team.thinkspace_common_user_ids = ids
            end
          end

          class TeamError < StandardError; end;

        end
      end
    end
  end
end
