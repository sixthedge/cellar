module Thinkspace
  module Team
    module Api
      class TeamsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize! except: [:teams_view, :team_users_view], module: :action_authorize_teams, params_ownerable: false
        totem_action_authorize! only:   [:teams_view, :team_users_view], read: [:teams_view, :team_users_view]
        totem_action_serializer_options

        def select
          controller_render(@teams)
        end

        def show
          controller_render(@team)
        end

        def teams_view
          teamable = totem_action_authorize.params_authable
          raise_team_exception("Teamable [id: #{teamable.id} class: #{teamable.class.name}] does not have collboration teams.")  unless teamable.collaboration?
          sub_action = totem_action_authorize.sub_action
          case sub_action
          when :collaboration_teams
            teams = can_update_teamable?(teamable) ? teamable.get_teams : teamable.get_teams(current_user)
          when :peer_review_teams
            teams = get_all_peer_review_teams(teamable)
          else
            raise_team_exception("Unknown sub_action [#{sub_action.inspect}].")
          end
          controller_render(teams)
        end

        def team_users_view
          teamable   = totem_action_authorize.params_authable
          scope      = teamable.thinkspace_team_teams
          sub_action = totem_action_authorize.sub_action
          case sub_action
          when :peer_review_users
            teams    = get_all_peer_review_teams(teamable) + teamable.get_teams(current_user)
            team_ids = teams.map(&:id)
            user_ids = Thinkspace::Team::TeamUser.where(team_id: team_ids).pluck(:user_id).uniq
            users    = Thinkspace::Common::User.where(id: user_ids)
          else
            raise_team_exception("Unknown sub_action [#{sub_action.inspect}].")
          end
          hash = controller_as_json(users)
          controller_render_json(hash)
        end

        private

        # TODO: Not sure what a 'reader' should return.  Was:
        # teams = can_update_teamable?(teamable) ? teamable.get_teams : team_class.viewer_teams_for_users(teamable, current_user)
        def get_all_peer_review_teams(teamable)
          if can_update_teamable?(teamable)
            teamable.get_teams
          else
            team_class.users_teams(teamable, current_user) + team_class.viewer_teams_for_users(teamable, current_user)
          end
        end

        def can_update_teamable?(teamable); can?(:update, teamable); end

        def team_class; Thinkspace::Team::Team; end

        def raise_team_exception(message='')
          raise TeamError, message
        end

        class TeamError < StandardError; end;

      end
    end
  end
end
