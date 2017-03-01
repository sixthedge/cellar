module Thinkspace
  module Casespace
    module Api
      class PhasesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize! read: [:load]
        totem_action_serializer_options

        def show
          controller_render(@phase)
        end

        def select
          controller_render(@phases)
        end

        def load
          controller_render_plural_root(@phase)  # Note: If left as a singular key on a query, ember-data ignores the record.
        end

        def submit
          can_update = can?(:update, assignment)
          ownerable  = totem_action_authorize.params_ownerable
          totem_action_authorize.send(:authorize_phase_ownerable, @phase, ownerable) if @phase.team_ownerable?
          processor = ::Thinkspace::Casespace::PhaseActions::Processor.new(@phase, current_user, action: :submit, can_update: can_update)
          processor.process_action(ownerable)
          phase_states = assignment.get_user_phase_states(assignment_phases, ownerable, current_user, can_update: can_update)
          hash         = controller_as_json(phase_states)
          hash[controller_plural_path] = []
          controller_render_json(hash)
        end

        private

        def assignment; @assignment ||= @phase.thinkspace_casespace_assignment; end

        def assignment_phases; @assignment_phases ||= assignment.thinkspace_casespace_phases.accessible_by(current_ability, :read); end

      end
    end
  end
end
