module Thinkspace
  module Authorization
    module Api
      class MetadataController < ::Totem::Settings.class.thinkspace.authorization_api_controller

        # The response is the metadata hash only e.g. not model attributes.

        def metadata
          controller_render_json(get_data)
        end

        private

        def data_name; :metadata; end

        include ControllerData

      end
    end
  end
end
