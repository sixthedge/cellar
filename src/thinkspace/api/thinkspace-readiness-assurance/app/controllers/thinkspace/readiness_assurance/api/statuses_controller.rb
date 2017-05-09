module Thinkspace
  module ReadinessAssurance
    module Api
      class StatusesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!

        def lock
          validate_status
          lock_status(question_id)
          publish
        end

        def unlock
          validate_status
          unlock_status(question_id)
          publish
        end

        def scribe
          validate_scribe_status
          get_assessment_question_ids.each do |qid|
            status = lock_status(qid)
            status[:locked].merge!(scribe: true)
          end
          publish
        end

        def unscribe
          validate_scribe_status
          get_assessment_question_ids.each do |qid|
            unlock_status(qid)
          end
          publish
        end

        private

        include ReadinessAssurance::ControllerHelpers::Base

        def validate_scribe_status
          validate_status
          access_denied "Assessment id #{@assessment.id} does not support scribes."  unless @assessment.scribe?
        end

        def validate_status
          response = @status.thinkspace_readiness_assurance_response
          access_denied "Status id #{@status.id} response is blank."  if response.blank?
          access_denied "Cannot read response id #{response.id}."  unless can?(:read, response)
          @assessment = response.thinkspace_readiness_assurance_assessment
          access_denied "Status id #{@status.id} response id #{response.id} assessment is blank." if @assessment.blank?
          access_denied "Cannot read assessment id #{@assessment.id}."  unless can?(:read, @assessment)
          @questions = @status.questions ||= Hash.new
          access_denied "Status questions is not a Hash."  unless @questions.is_a?(Hash)
        end

        def get_question_status(qid)
          status = (@questions[qid] ||= Hash.new)
          access_denied "Status question is not a hash."  unless status.is_a?(Hash)
          status
        end

        def get_assessment_question_ids; @assessment.questions.map {|h| h['id']}; end

        def lock_status(qid);   get_question_status(qid).merge!(locked: current_user_json); end
        def unlock_status(qid); get_question_status(qid).delete('locked'); end

        def save_status
          access_denied "Could not save status.  Validation errors: #{@status.errors.messages}."  unless @status.save
        end

        def publish
          save_status
          value = {questions: @questions}
          pubsub.data.
            room(pubsub_room).
            room_event(:status).
            value(value).
            publish
          controller_render_json Hash.new
        end

      end
    end
  end
end
