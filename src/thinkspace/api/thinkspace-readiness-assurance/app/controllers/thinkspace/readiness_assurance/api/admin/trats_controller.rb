module Thinkspace
  module ReadinessAssurance
    module Api
      module Admin
        class TratsController < ::Totem::Settings.class.thinkspace.authorization_api_controller

          def team_users
            controller_render_json(get_team_json)
          end

          def assessment
            set_trat_assessment
            serializer_options.remove_all
            serializer_options.add_attributes(:settings, :answers)
            controller_render(@assessment)
          end

          def responses
            set_trat_assessment
            serializer_options.remove_all_except(
              :thinkspace_readiness_assurance_assessment,
              :thinkspace_readiness_assurance_response,
              :thinkspace_readiness_assurance_status,
              :thinkspace_readiness_assurance_chat,
            )
            serializer_options.include_association(
              :thinkspace_readiness_assurance_chat,
              :thinkspace_readiness_assurance_status,
            )
            responses = Array.new
            phase     = get_trat_phase
            phase_teams(phase).each do |team|
              response = @assessment.find_or_create_response_and_association_records(team, user: current_user)
              responses.push(response)
            end
            controller_render(responses)
          end

          def overview
            set_trat_assessment
            controller_render_no_content
          end

          def phase_states
            validate_space
            trat = trat_handler_class.new(get_trat_phase, current_user, trat_params)
            trat_params[:admin_message] ||= "TRAT phase set to '#{trat.humanized_phase_state}'"
            trat.update_phase_states
            controller_render_no_content
          end

          def progress_report
            set_trat_assessment
            controller_render_json(@assessment.progress_report)
          end

          private

          include ReadinessAssurance::ControllerHelpers::Base
          include ReadinessAssurance::ControllerHelpers::Admin

          def get_team_json
            json         = Hash.new
            phase        = get_trat_phase
            json[:teams] = team_json(phase, phase_teams(phase), set_all_team_users: true)
            if (no_team_users = (get_phase_users(phase) - team_json_all_team_users)).present?
              user_json = no_team_users.map {|user| get_user_json(user)}
              json[:no_teams] = Hash(users: user_json)
            end
            json
          end

          def get_phase_users(phase)
            space.thinkspace_common_users.scope_active.scope_read
          end

        end
      end
    end
  end
end
