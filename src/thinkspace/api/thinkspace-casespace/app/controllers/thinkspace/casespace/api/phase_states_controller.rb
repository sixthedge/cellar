module Thinkspace
  module Casespace
    module Api
      class PhaseStatesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize! ownerable_ability_action: :gradebook

        def create
          @phase_state.phase_id = params_association_id('phase_id')
          authorize_state_change
          @phase_state.current_state = :neutral  if @phase_state.current_state.blank?
          process_current_state
          serializer_options.remove_association :ownerable
          serializer_options.remove_association :thinkspace_common_user
          controller_save_record(@phase_state)
        end

        def update
          authorize_state_change
          process_current_state
          serializer_options.remove_association :ownerable
          serializer_options.remove_association :thinkspace_common_user
          controller_save_record(@phase_state)
        end

        def roster_update
          authorize_state_change
          if (score = params_root[:new_score]).present?
            phase_score       = @phase_state.thinkspace_casespace_phase_score
            phase_score       = @phase_state.build_thinkspace_casespace_phase_score(user_id: current_user.id)  if phase_score.blank?
            phase_score.score = score
            raise "Could not save phase score [#{phase_score.inspect}]"  unless phase_score.save
          end
          if params_root[:new_state].present?
            process_current_state
            raise "Could not save phase state [#{@phase_state.inspect}]"  unless @phase_state.save
          end
          controller_render_no_content
        end

        private

        def authorize_state_change
          phase      = @phase_state.thinkspace_casespace_phase
          assignment = phase.thinkspace_casespace_assignment
          unless (can?(:gradebook, assignment) && @phase_state.phase_id == totem_action_authorize.params_authable.id)
            # Additional information to error message before raising unauthorized exception (since states are sensitive).
            message  = "Unauthorized attempt to update a user phase state!\n"
            message += "Current user [#{current_user.inspect}]\n"
            message += "Phase [#{phase.inspect}]\n"
            message += "PhaseState [#{@phase_state.inspect}]"
            logger.error message
            authorize!(:gradebook, assignment)  # raise unauthorized error
          end
        end

        def process_current_state
          case (params_root[:new_state] || '').to_sym
          when :locked
            @phase_state.lock_phase
          when :unlocked
            @phase_state.unlock_phase
          when :completed
            @phase_state.complete_phase
          else
          end
        end

      end
    end
  end
end
