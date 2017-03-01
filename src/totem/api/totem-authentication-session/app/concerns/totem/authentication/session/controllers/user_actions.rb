module Totem
  module Authentication
    module Session
      module Controllers
        module UserActions

          # ###
          # ### Session User Actions.
          # ###

          def sign_in
            api_session  = totem_sign_in_user!
            hash         = controller_as_json(current_user)
            controller_after_json(hash)
            hash[:token] = api_session.authentication_token
            controller_render_json(hash)
          end

          def sign_out
            totem_sign_out_user!
            controller_render_no_content
          end

          # Authenticates the user (via before_action) and resets the session timeout.
          # Used by the ember application when no server calls are performed, but the user is active.
          # Must be called by ember on the platform's api 'users' controller which extends this controller.
          # The platform's routes must include: get :stay_alive, on: :collection
          def stay_alive
            update_api_session_alive(current_user)
            render json: {"#{current_user.class.name.underscore}" => []}, status: :ok
          end

          # Authenticates the user's token and email are valid (e.g. token has not expired) but
          # does 'not' update the api_session 'updated_at' like 'stay_alive' or return any json.
          # The user's token and email are validated by the authentication controller's
          # before_action ':totem_authenticate_user_from_token!'.  If this does not raise
          # an exception (e.g. a session timout), then is still valid.
          # Used by the 'ember-cli-simple-auth' authenticator when restoring a session
          # (e.g. page reload, browser is opened by another user) to determine if the
          # browser's local storage is still valid (user token and user email).
          # If not valid, the authenticator routes the user to the sign_in page.
          def validate
            raise SessionCredentialsInvalid, "Invalid credentials."  if current_user.blank?
            raise SessionCredentialsInvalid, "Invalid user."         unless current_user.id.to_s == params[:user_id]
            controller_render(current_user)
          end

        end
      end
    end
  end
end
