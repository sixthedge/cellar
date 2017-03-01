module Thinkspace
  module ReadinessAssurance
    module Api
      class StatusesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!

        def lock
          status = validate_and_get_question_status
          status.merge!(locked: current_user_json)
          save_status
          publish(status)
        end

        def unlock
          status = validate_and_get_question_status
          status.delete('locked')
          save_status
          publish(status)
        end

        private

        include ReadinessAssurance::ControllerHelpers::Base

        def validate_and_get_question_status
          response = @status.thinkspace_readiness_assurance_response
          access_denied "Status id #{@chat.id} response is blank."  if response.blank?
          @assessment = response.thinkspace_readiness_assurance_assessment
          questions   = @status.questions
          access_denied "Status questions is not a Hash."  unless questions.is_a?(Hash)
          question_status = (questions[question_id] ||= Hash.new)
          access_denied "Status question is not a hash."  unless question_status.is_a?(Hash)
          question_status
        end

        def save_status
          access_denied "Could not save status.  Validation errors: #{@status.errors.messages}."  unless @status.save
        end

        def publish(status)
          pubsub.data.
            room(pubsub_room).
            room_event(:status).
            value({question_id: question_id, status: status}).
            publish
          controller_render_no_content
        end

      end
    end
  end
end
