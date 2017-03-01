module Totem
  module Authentication
    module Session

      class AuthenticationController < ::Totem::Settings.class.totem.application_controller
        before_action :invalid_request

        private

        def invalid_request
           raise InvalidAuthentication, "Only API session are protected."
        end

      end

    end
  end
end
