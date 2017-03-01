module Thinkspace
  module Authorization
    module Api
      class AbilitiesController < ::Totem::Settings.class.thinkspace.authorization_api_controller

        # The response is the ability hash only e.g. not model attributes.

        def abilities
          controller_render_json(get_data)
        end

        private

        def data_name; :ability; end

        include ControllerData

      end
    end
  end
end
