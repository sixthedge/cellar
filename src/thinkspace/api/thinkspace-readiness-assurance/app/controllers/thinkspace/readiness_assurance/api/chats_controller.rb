module Thinkspace
  module ReadinessAssurance
    module Api
      class ChatsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!

        def add
          value = validate_and_set_chat_data
          if team?
            publish(value)
          else
            access_denied "Chat messages are only for team based ownerables [ownerable: #{ownerable.inspect}]"
          end
        end

        private

        include ReadinessAssurance::ControllerHelpers::Base

        def validate_and_set_chat_data
          response = @chat.thinkspace_readiness_assurance_response
          access_denied "Chat id #{@chat.id} response is blank."  if response.blank?
          @assessment = response.thinkspace_readiness_assurance_assessment
          message     = params[:message]
          access_denied "Chat message is blank."  if message.blank?
          messages = @chat.messages
          access_denied "Chat messages is not a Hash."  unless messages.is_a?(Hash)
          question_messages = (messages[question_id] ||= Array.new)
          access_denied "Chat question messages is not an array."  unless question_messages.is_a?(Array)
          chat_message = {message: message, time: Time.now.utc}.merge(current_user_json)
          question_messages.push(chat_message)
          access_denied "Could not save chat.  Validation errors: #{@chat.errors.messages}."  unless @chat.save
          {question_id: question_id, message: chat_message}
        end

        def publish(value)
          pubsub.data.
            room(pubsub_room).
            room_event(:chat).
            value(value).
            publish
          controller_render_no_content
        end

      end
    end
  end
end
