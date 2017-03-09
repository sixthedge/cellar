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

          def update_transform
            @team_set.transform = params[:transform]
            controller_render(@team_set)
          end

          def explode
            ActiveRecord::Base.transaction do 
              transform      = @team_set.transform
              trans_team_ids = transform['teams'].map { |t| t['id'] }
              cur_team_ids   = @team_set.thinkspace_team_teams.pluck(:id)

              ## Delete excluded teams
              deleted_team_ids = cur_team_ids - trans_team_ids
              Thinkspace::Team::Team.where(id: deleted_team_ids).destroy_all

              new_teams = transform['teams'].select { |t| t.has_key?('new') }
              existing_teams = transform['teams'].select { |t| !t.has_key?('new') }

              new_teams.each do |team|
                new_team = Thinkspace::Team::Team.create(title: team['title'], color: team['color'], team_set_id: @team_set.id, authable: @team_set.thinkspace_common_space)
                new_team.thinkspace_common_users << Thinkspace::Common::User.where(id: team['user_ids'])
                team['id']  = new_team.id
                team.delete('new')
              end

              existing_teams.each do |team|
                record = Thinkspace::Team::Team.find(team['id'])
                record.title = team['title']
                record.thinkspace_team_team_users.destroy_all
                record.thinkspace_common_users << Thinkspace::Common::User.where(id: team['user_ids'])
                record.save
              end

              @team_set.scaffold  = @team_set.transform.deep_dup
              @team_set.transform = nil

              controller_save_record(@team_set)
            end

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
