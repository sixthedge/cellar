module Thinkspace
  module Common
    module Concerns
      module SerializerOptions
        module Admin
          module Spaces

            def common_admin_serializer_options(serializer_options)
              serializer_options.include_metadata
              serializer_options.remove_association  :thinkspace_common_users,  scope: :root
              serializer_options.remove_association  :thinkspace_common_spaces, scope: :thinkspace_common_users
              serializer_options.include_association :thinkspace_common_space_types, scope: :root
              serializer_options.include_association :thinkspace_common_owners,      scope: :root

              serializer_options.ability_actions  :update, scope: :root
              serializer_options.authorize_action :read_space_owners, :thinkspace_common_owners,      scope: :root
              serializer_options.authorize_action :read_space_owners, :thinkspace_common_space_users, scope: :root

              # Scope the assignments association to include 'inactive' assignment 'ids' only when can update the space.
              serializer_options.scope_association(:thinkspace_wips_casespace_assignments,
                scope_assignment_association: [:record, :current_ability]
              )
            end

            def create(serializer_options)
              common_admin_serializer_options(serializer_options)
            end

            def update(serializer_options)
              common_admin_serializer_options(serializer_options)
            end

            def clone(serializer_options)
              common_admin_serializer_options(serializer_options)
            end

            def roster(serializer_options)
              serializer_options.include_association :thinkspace_common_space_users, scope: :root
              serializer_options.include_association :thinkspace_common_disciplines, scope: :root
            end

            def invitations(serializer_options)
              serializer_options.include_association :thinkspace_common_invitations
              serializer_options.scope_association :thinkspace_common_invitations, where: {accepted_at: nil}
            end

            def teams(serializer_options)
              serializer_options.include_association :thinkspace_team_teams
              serializer_options.include_association :thinkspace_team_category, scope: :thinkspace_team_teams
              serializer_options.include_association :thinkspace_common_users, scope: :thinkspace_team_teams
            end

            def team_sets(serializer_options)
              serializer_options.include_association :thinkspace_team_team_sets
              #serializer_options.include_association :thinkspace_team_teams, scope: :thinkspace_team_team_sets
              #serializer_options.include_association :thinkspace_team_team_users, scope: :thinkspace_team_teams
              #serializer_options.include_association :thinkspace_common_users, scope: :root
            end

            def invite; end
            def import; end
            def search; end

          end
        end
      end
    end
  end
end
