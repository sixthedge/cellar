module Thinkspace
  module ReadinessAssurance
    module Api
      module Admin
        class AssessmentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class, except: [:progress_report]

          def update
            @assessment.questions = params_root[:questions]
            @assessment.settings  = params_root[:settings]
            @assessment.sync_assessments
            controller_save_record(@assessment)
          end

          def progress_report
            set_irat_assessment
            irat_phase = @assessment.authable
            set_trat_assessment
            trat_phase = @assessment.authable

            irat_phase_states = irat_phase.thinkspace_casespace_phase_states.scope_by_ownerable_type('Thinkspace::Common::User')
            trat_phase_states = trat_phase.thinkspace_casespace_phase_states.scope_by_ownerable_type('Thinkspace::Team::Team')
            irat_completed    = irat_phase_states.scope_completed.count
            trat_completed    = trat_phase_states.scope_completed.count
            irat_total        = irat_phase_states.count
            trat_total        = trat_phase_states.count

            results           = HashWithIndifferentAccess.new(irat: {}, trat: {})
            results['irat']   = {total: irat_total, completed: irat_completed, state: irat_phase.default_state, release_at: irat_phase.release_at, due_at: irat_phase.due_at}
            results['trat']   = {total: trat_total, completed: trat_completed, state: trat_phase.default_state, release_at: trat_phase.release_at, due_at: trat_phase.due_at}
            controller_render_json(results)
          end

          private

          include ReadinessAssurance::ControllerHelpers::Base
          include ReadinessAssurance::ControllerHelpers::Admin

        end
      end
    end
  end
end
