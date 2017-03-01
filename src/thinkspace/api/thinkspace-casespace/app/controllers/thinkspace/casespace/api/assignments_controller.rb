module Thinkspace
  module Casespace
    module Api
      class AssignmentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize! only: :view, params_authable_required: true
        totem_action_authorize! only: :phase_states, module: false
        totem_action_serializer_options

        def show
          controller_render(@assignment)
        end

        def select
          @assignments = @assignments.where(id: params[:ids])
          controller_render(@assignments)
        end

        def view
          case totem_action_authorize.sub_action
          when :gradebook_teams
            gradebook_teams
          when :gradebook_users
            gradebook_users
          else
            raise_view_exception "Unknown view sub action [#{totem_action_authorize.sub_action.inspect}]."
          end
         end

        def phase_states
          controller_render(@assignment, json_method: :assignment_phase_states)
        end

        def roster
          sub_action = (params[:auth] && params[:auth][:sub_action]) || ''
          case sub_action.to_sym
          when :assignment_roster
            hash = assignment_roster_scores(@assignment)
            controller_render_json(hash)
          when :phase_roster
            phase = validate_and_get_phase
            hash  = phase_roster_scores(phase)
            controller_render_json(hash)
          else
            raise_view_exception "Unknown roster sub action [#{sub_action.inspect}]."
          end
         end

        private

        def assignment_phase_states
          can_update = can?(:update, @assignment)
          ownerable  = totem_action_authorize.params_ownerable
          if !can_update && ownerable.kind_of?(current_user.class) && ownerable != current_user
            raise_access_denied_exception "Unauthorized assignment phase states request.", :phase_states, controller_model_class
          end
          phase_states = @assignment.get_user_phase_states(assignment_phases, ownerable, current_user, can_update: can_update)
          if can_update
            serializer_options.include_association :thinkspace_casespace_phase_score, scope: :root
          else
            serializer_options.remove_association :thinkspace_casespace_phase_score, scope: :root
          end
          controller_json(phase_states)
        end

        def validate_and_get_phase
          action = self.action_name.to_sym
          id     = params[:auth] && params[:auth][:phase_id]
          raise_access_denied_exception "Roster phase id is blank.", action, controller_model_class  if id.blank?
          phase = assignment_phases.find_by(id: id)
          raise_access_denied_exception "Roster phase [id: #{id.inspect}] not found for assignment.", action, controller_model_class  if phase.blank?
          authorize!(:update, phase)
          phase
        end

        def gradebook_users
          space = @assignment.thinkspace_common_space
          controller_render_view(space)
        end

        def gradebook_teams
          teams  = Array.new
          phases = assignment_phases
          phases.each {|phase| teams.push phase.get_teams}
          teams = [teams].flatten.compact
          controller_render(teams)
        end

        def assignment_phases; @assignment_phases ||= @assignment.thinkspace_casespace_phases.accessible_by(current_ability, :read); end

        include Thinkspace::Casespace::Concerns::Gradebook::PhaseScores

        def raise_view_exception(message='')
          raise ViewError, message
        end

        class ViewError < StandardError; end;

      end
    end
  end
end
