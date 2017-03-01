module Thinkspace
  module ReadinessAssurance
    module Api
      module Admin
        class MessagesController < ::Totem::Settings.class.thinkspace.authorization_api_controller

          def to_users
            validate_space
            handler = handler_class.new(nil, current_user, message_params)
            handler.set_assignment(assignment)
            handler.publish_messages_to_users
            controller_render_no_content
          end

          private

          include ReadinessAssurance::ControllerHelpers::Base
          include ReadinessAssurance::ControllerHelpers::Admin

        end
      end
    end
  end
end
