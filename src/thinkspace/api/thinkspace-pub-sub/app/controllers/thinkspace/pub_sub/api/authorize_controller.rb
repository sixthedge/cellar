module Thinkspace
  module PubSub
    module Api
      class AuthorizeController < ::Totem::Settings.class.thinkspace.authorization_api_controller

        def authorize
          params.permit!
          # params.permit(:auth, :auth_key, :rooms, :room_type)
          # sleep 5 # TESTING ONLY for timeout
          validate unless current_user.superuser?
          controller_render_json({can: true})
        end

        private

        include PubSub::AuthorizeHelpers
        include PubSub::AuthHelpers


        def validate
          validate_authorize
          validate_rooms(get_rooms, get_room_type)
        end

        def validate_authorize
          if has_authable?
            # taa = new_totem_action_authorize
            # taa.process
# TODO: What should the rules be here? Note: rooms available via get_rooms.
#       - e.g. how validate if user on team for a team room?
#       - e.g. user can access a room?
# TODO: Can some convention be used for team room name?
#       - e.g. team room match ownerable?
          else
# TODO: What should the rules be here?  e.g. for a space, assignment, etc.
#       - e.g. how validate if can access a space room?
          end
        end

      end
    end
  end
end
