module Thinkspace
  module ReadinessAssurance
    module Api
      class ResponsesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        totem_action_serializer_options

        def show
          controller_render(@response)
        end

        def update
          validate_and_set_response_data
          score_response
          if trat?
            publish_trat_response
            controller_render_no_content
          else
            controller_render(@response)
          end
          publish_progress_report
        end

        private

        include ReadinessAssurance::ControllerHelpers::Base

        def validate_and_set_response_data
          @assessment = @response.thinkspace_readiness_assurance_assessment
          access_denied "Response id #{@response.id} assessment is blank."  if @assessment.blank?
          answers = params_root[:answers]
          access_denied "Response 'answers' is not a hash."  unless answers.is_a?(Hash)
          justifications = params_root[:justifications]
          access_denied "Response 'justifications' is not a hash."  unless justifications.is_a?(Hash)
          @response.answers        = answers
          @response.justifications = justifications
          access_denied "Unknown response type (not IRAT or TRAT) [id: @response.id]." unless (irat? || trat?)
          access_denied "TRAT ownerable is not a team for response [id: @response.id] with ownerable [#{ownerable.class.name} id:#{ownerable.id}]." if trat? && !team?
        end

        def score_response
          ownerable = totem_action_authorize.params_ownerable
          authable  = totem_action_authorize.params_authable
          options   = {assessment: @assessment, ifat_only: true}  # only score ifat questions on an update
          handler   = handler_class.new(authable, current_user, nil, options)
          handler.score_response(@response, ownerable)
        end

        def publish_trat_response
          json = controller_json(@response, plural_root: true)
          pubsub.data.
            room(pubsub_room).
            room_event(:response).
            value(json).
            publish
        end

        def publish_progress_report
          @assessment     = @response.thinkspace_readiness_assurance_assessment
          assignment      = @assessment.authable.thinkspace_casespace_assignment
          room            = pubsub.room_for(assignment, 'admin')
          progress_report = @assessment.progress_report
          pubsub.data.
            room(room).
            room_event(:progress_report).
            value(progress_report).
            publish
        end

      end
    end
  end
end
