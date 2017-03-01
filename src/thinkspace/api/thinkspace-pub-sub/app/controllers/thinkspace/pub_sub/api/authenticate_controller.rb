module Thinkspace
  module PubSub
    module Api
      class AuthenticateController < ::Totem::Settings.class.thinkspace.authorization_api_controller

        # TODO: Add authenticate rules.
        def authenticate
          # sleep 5 # TESTING ONLY for timeout
          controller_render_json({can: true, user_data: current_user_data})
        end

        private

        include PubSub::AuthHelpers

      end
    end
  end
end
