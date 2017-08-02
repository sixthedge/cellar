module Thinkspace
  module ReadinessAssurance
    module Api
      module Admin
        class AssessmentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class, except: [:progress_report]

          def update
            if Thinkspace::ReadinessAssurance::Assessment.assignment_has_responses?(@assessment.get_assignment)
              if @assessment.transform.present?
                @assessment.transform = params_root[:transform]
              else 
                options = {
                  transform: params_root,
                  questions: {
                    label: true,
                    order: true
                  }
                }
                if Thinkspace::ReadinessAssurance::Deltas::Assessment.new(@assessment, options).has_changes?
                  @assessment.transform = {
                    questions: params_root[:questions],
                    settings:  params_root[:settings],
                    answers:   params_root[:answers]
                  }
                end
              end
            else
              @assessment.questions = params_root[:questions]
              @assessment.settings  = params_root[:settings]
              @assessment.answers   = params_root[:answers]
            end       
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

          def sync
            options = params_root[:options]
            @assessment.sync(options)
            controller_render(@assessment)
          end
        
          private

          include ReadinessAssurance::ControllerHelpers::Base
          include ReadinessAssurance::ControllerHelpers::Admin

        end
      end
    end
  end
end
