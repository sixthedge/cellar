module Thinkspace
  module Casespace
    module Concerns
      module Authorize
        module Teams

            private

            # ###
            # ### Method overrides required by totem_action_authorize!.
            # ###
            def authorize_authable_classes;  [space_class, assignment_class, phase_class]; end  # Classes allowed to be an 'authable'.

            # ###
            # ### Main authorize processing (and method override).
            # ###
            def action_authorize!(space=record_authable)
              # Do not do any additional authorization if superuser.
              return if current_user.superuser?
              #
              case
              when space.blank?                                then access_denied("Team authable space is blank.")
              when current_record.blank?                       then access_denied("Team association record is blank.")
              when can_update_record_authable?                 then return
              when current_record.is_a?(team_class)            then authorize_is_a_team_member(space)
              when current_record.is_a?(team_user_class)       then authorize_team_user(space)
              when current_record.is_a?(team_teamable_class)   then authorize_team_teamable(space)
              when current_record.is_a?(team_viewer_class)     then authorize_team_viewerable(space)
              else
                access_denied("Cannot access '#{current_record.class.name}.#{current_record.id}' in space [id: #{space.id}].")
              end
            end

            # ### Authorize Team Records.

            def authorize_team_user(space)
              if is_create?
                user_id = params_root[:user_id]
                access_denied("Team user params user_id is blank.")  if user_id.blank?
                current_record.user_id = user_id  # totem_action_authorize sets a 'user_id' to current_user; set to params user_id
                debug_message("+record.user_id", "set to [user_id: #{user_id}] by teams authorize module.") if debug?
              end
              authorize_is_space_user(space, current_record.user_id)
            end

            def authorize_team_teamable(space)
              teamable = current_record.teamable
              access_denied("Team teamable teamable is blank.")  if teamable.blank?
              access_denied("Team teamable teamable does not respond to :get_space.")  unless teamable.respond_to?(:get_space)
              access_denied("Team teamable [#{teamable.class.name.inspect} id: #{teamable.id}] is not related to space [id: #{space.id}].")  unless teamable.get_space == space
              debug_message("@authorized", "teamable [#{teamable.class.name.inspect} id: #{teamable.id}] belongs to space.") if debug?
            end

            def authorize_team_viewerable(space)
              viewerable = current_record.viewerable
              access_denied("Team teamable viewerable is blank.")  if viewerable.blank?
              case viewerable.class.name
              when user_class.name
                authorize_is_space_user(space, viewerable)
              when team_class.name
                authorize_is_space_team(space, viewerable)
                authorize_current_user_can_view_team(viewerable)
              else
                access_denied("Team viewerable [#{viewerable.class.name.inspect} id: #{viewerable.id}] is not user or team.")
              end
              debug_message("@authorized", "viewerable [#{viewerable.class.name.inspect} id: #{viewerable.id}] belongs to space.") if debug?
            end

            def authorize_is_a_team_member(space)
              team = current_record
              authorize_is_space_user(space, current_user)
              authorize_is_space_team(space, team)
              authorize_current_user_can_view_team(team)
              team_member = team.thinkspace_team_team_users.where(user_id: current_user.id).exists?
              access_denied("User [id: #{current_user.id}] is not a member of team [id: #{team.id}].") unless team_member
              debug_message("@authorized", "user [id: #{current_user.id}] is a member of team [id: #{team.id}].") if debug?
            end

            # ### Common helpers

            def authorize_is_space_user(space, user)
              access_denied("Team user [user_id: #{user_id}] is not a space user.")  unless space.is_space_user?(user)
            end

            def authorize_is_space_team(space, team)
              authable = team.authable
              access_denied("Team [id: #{team.id}] authable is blank.")    if authable.blank?
              access_denied("Team [id: #{team.id}] is not a space team.")  unless authable == space
            end

            def authorize_current_user_can_view_team(team)
              access_denied("Current user [id: #{current_user.id}] cannot view team [id: #{team.id}].")  unless team_class.users_can_view_teams?(current_user, team)
            end

            # Common classes used in this module.
            def space_class;         Thinkspace::Common::Space; end
            def user_class;          Thinkspace::Common::User; end
            def phase_class;         Thinkspace::Casespace::Phase; end
            def assignment_class;    Thinkspace::Casespace::Assignment; end
            def team_class;          Thinkspace::Team::Team; end
            def team_user_class;     Thinkspace::Team::TeamUser; end
            def team_teamable_class; Thinkspace::Team::TeamTeamable; end
            def team_viewer_class;   Thinkspace::Team::TeamViewer; end

        end
      end
    end
  end
end
