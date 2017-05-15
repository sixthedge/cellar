module Thinkspace
  module Common
    module Api
      module Admin
        class SpacesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_serializer_options
          before_action :set_scope, only: [:roster]
          totem_filter only: [:roster]

          def update
            @space.title = params_root[:title]
            controller_save_record(@space)
          end

          def create
            # Must do this to regenerate ability due to space_ids not having the new record.
            # => Without this, update on the record will return as false.
            @current_ability                     = nil 
            @space.title                         = params_root[:title]
            @space.thinkspace_common_space_types = [get_space_type]
            @space.state                         = 'active'
            @space.save ? add_user_to_space_as_owner_and_render : controller_render_error(@space)
          end

          def invite
            email = params[:email].strip.downcase
            role  = params[:role]
            # Create a new user to mimick the import process to utilize the same underlying process.
            # => The `process_imported_user` will check to see if the user already exists, etc.
            @user = user_class.new(email: email)
            @user = @space.process_imported_user(@user, current_user, role)
            controller_render(@user)
          end

          def clone
            cloned_space = @space.cyclone_with_notification(current_user) # DelayedJob
            controller_render(@space)
          end

          def roster
            controller_render(@space.group(:id))
          end

          def teams
            # TODO: Take into account team_set_id?
            controller_render(@space)
          end

          def team_sets
            ensure_default_team_set
            controller_render(@space)
          end

          def search
            type = params[:type] || 'roster'
            case type
            when 'roster'
              results = search_roster.limit(10).to_a
            end
            controller_render(results)
          end

          private

          # # Roster
          # ## Searching
          def search_roster
            terms = params[:terms] || ''
            sanitized = @space.class.send(:sanitize_sql_array, ["to_tsquery('english', ?)", terms.gsub(/\s/,"+")])
            @space.thinkspace_common_users.where(%{
              (
                to_tsvector('english', thinkspace_common_users.first_name) ||
                to_tsvector('english', thinkspace_common_users.last_name) ||
                to_tsvector('english', thinkspace_common_users.email)
              ) @@ #{sanitized}
            })
          end

          # ## Helpers
          def set_scope
            # TODO: Workaround to set the scope for TotemFilter, since we are not scoping the actual space.
            @space = @space.thinkspace_common_users
          end

          # # Space
          # ## Helpers
          def add_user_to_space_as_owner_and_render
            @space.add_user_as_owner(current_user)
            controller_render(@space)
          end

          def ensure_default_team_set
            team_sets = @space.thinkspace_team_team_sets
            default   = team_sets.scope_default
            if team_sets.empty?
              Thinkspace::Team::TeamSet.create(title: 'Default', default: true, space_id: @space.id)
            elsif default.empty?
              team_set = team_sets.first
              team_set.set_default
            end
          end

          # # Helpers
          def get_space_type; space_type_class.find_by(title: 'Casespace'); end
          def user_class;       Thinkspace::Common::User;       end
          def space_type_class; Thinkspace::Common::SpaceType;  end

        end
      end
    end
  end
end
