module Thinkspace
  module ReadinessAssurance
    module Api
      module Admin
        class IratsController < ::Totem::Settings.class.thinkspace.authorization_api_controller

          def assessment
            set_irat_assessment
            serializer_options.remove_all
            serializer_options.add_attributes(:settings, :answers)
            controller_render(@assessment)
          end

          # TODO: if all teams transitioned, lock the phase? (due_at will be set for timetable[phase] plus any timetable[phase][ownerable])
          def to_trat
            validate_space
            irat_params[:admin_message] ||= 'IRAT transition to TRAT'
            irat = irat_handler_class.new(get_irat_phase, current_user, irat_params)
            trat = trat_handler_class.new(get_trat_phase, current_user, trat_params)
            irat.to_trat(trat)
            controller_render_no_content
          end

          def phase_states
            validate_space
            irat = irat_handler_class.new(get_irat_phase, current_user, irat_params)
            irat_params[:admin_message] ||= "IRAT phase set to '#{irat.humanized_phase_state}'"
            irat.update_phase_states
            controller_render_no_content
          end

          def progress_report
            set_irat_assessment
            controller_render_json(@assessment.progress_report)
          end

          private

          include ReadinessAssurance::ControllerHelpers::Base
          include ReadinessAssurance::ControllerHelpers::Admin

        end
      end
    end
  end
end
