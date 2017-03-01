module Test; module Ability; module Controllers; module Thinkspace; module Casespace; module Api

  class AssignmentsController
    def assignment_error(route); route.assert_raise_any_error(/unknown.*sub action/i); end
    def setup_view_can_update_authorized(route);   assignment_error(route); end
    def setup_view_reader(route);                  assignment_error(route); end
    def setup_roster_can_update_authorized(route); assignment_error(route); end
    def setup_select(route); route.assert_authorized; end  # even though authorized, the ids are scoped accessable by the user
  end

  class PhaseStatesController
    def setup_roster_update_can_update_authorized(route); route.include_model_in_params; end
    def before_save_can_update_authorized(route)
      # The phase state ownerable for updaters is a 'read' user (not themselved).
      phase       = route.dictionary_phase
      phase_state = route.dictionary_phase_state
      space       = phase.get_space
      space_user  = route.space_user_class.find_by(space_id: space.id, role: :read)
      return unless space_user.present?
      read_user             = route.user_class.find_by(id: space_user.user_id)
      phase_state.ownerable = read_user
    end
  end

  module Admin
    class AssignmentsController
      def setup_phase_order_can_update_authorized(route); route.assert_raise_any_error(/phase order.*array/i); end
      def setup_create_can_update_authorized(route);      route.assert_raise_any_error(/couldn't find.*casemanagertemplate with 'id'/i); end
      def setup_clone_can_update_authorized(route);       route.assert_raise_any_error(/cannot clone.*without a space id/i); end
      def setup_templates_can_update_unauthorized(route); route.assert_authorized; end
    end
    class PhasesController
      def setup_clone_can_update(route); route.assert_raise_any_error(/without.*template id/i); end
      def setup_templates_can_update_unauthorized(route); route.assert_authorized; end
    end
  end

end; end; end; end; end; end
