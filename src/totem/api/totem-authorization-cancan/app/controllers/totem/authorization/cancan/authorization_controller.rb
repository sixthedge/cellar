module Totem
  module Authorization
    module Cancan
      class AuthorizationController < Totem::Settings.class.totem.authentication_controller

        protected

        include ::Totem::Authorization::Cancan::Controllers::CurrentAbility

      end
    end
  end
end
