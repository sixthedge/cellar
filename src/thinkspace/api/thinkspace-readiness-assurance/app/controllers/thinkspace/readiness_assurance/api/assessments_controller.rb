module Thinkspace
  module ReadinessAssurance
    module Api
      class AssessmentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize! read: [:teams]
        totem_action_serializer_options

        def show
          validate_phase_state
          controller_render(@assessment)
        end

        def view
          generate_auto_timer if auto_timer?
          create_chat = team? || can_update?
          @assessment.find_or_create_response_and_association_records(ownerable, user: current_user, create_chat: create_chat)
          controller_render_view(@assessment)
        end

        def trat_overview
          json = get_trat_overview_json
          controller_render_json(json)
        end

        def teams
          json = !team? && can_update? ? [] : team_json_with_current_user(authable, ownerable)
          controller_render_json(json)
        end

        private

        include ReadinessAssurance::ControllerHelpers::Base

        def validate_phase_state
          state = authable.find_or_create_state_for_ownerable(ownerable)
          access_denied "Phase state is locked."  if state.locked?
        end

        def get_trat_overview_json
          phase       = totem_action_authorize.params_authable
          @assignment = phase.thinkspace_casespace_assignment
          assessment  = get_trat_assessment
          aphase      = assessment.authable
          questions   = assessment.questions
          teams       = phase_teams(aphase)
          data        = Array.new
          teams.each do |team|
            response       = assessment.thinkspace_readiness_assurance_responses.find_by(ownerable: team)
            answers        = (response && response.answers)        || Hash.new
            justifications = (response && response.justifications) || Hash.new
            data.push({team_id: team.id, answers: answers, justifications: justifications})
          end
          {data: data, questions: questions, teams: team_json_with_current_user(aphase, teams)}
        end

        def auto_timer?; irat? && @assessment.auto_timer?; end

        def generate_auto_timer
          hash = @assessment.get_auto_timer
          return unless hash.is_a?(Hash)
          handler    = handler_class.new(authable, current_user, {})
          auto_timer = hash.deep_symbolize_keys
          duration   = handler.auto_timer_hash_to_duration(auto_timer[:duration])
          return if duration == 0
          options = {
            timetable:      true,
            origin:         self,
            timer_end_at:   handler.auto_timer_now + duration,
            timer_settings: auto_timer.merge(message: "Your phase #{@assessment.title.inspect} is due")
          }
          handler.auto_timer(options)
        end

      end
    end
  end
end
