module Thinkspace
  module Casespace
    module Api
      class PhaseScoresController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize! ownerable_ability_action: :gradebook

        def create
          # @phase_score.phase_id = params_association_id('phase_id')
          authorize_score_change
          @phase_score.score = params_root[:score]
# serializer_options.remove_association :ownerable
serializer_options.remove_association :thinkspace_common_user
          controller_save_record(@phase_score)
        end

        def update
          authorize_score_change
          @phase_score.score = params_root[:score]
serializer_options.remove_association :ownerable
serializer_options.remove_association :thinkspace_common_user
          controller_save_record(@phase_score)
        end

        private

        def authorize_score_change
          phase      = @phase_score.thinkspace_casespace_phase
          assignment = phase.thinkspace_casespace_assignment
          unless can?(:gradebook, assignment)
            # Additional information to error message before raising unauthorized exception (since scores are sensitive).
            message  = "Unauthorized attempt to update a user phase score!\n"
            message += "Current user [#{current_user.inspect}]\n"
            message += "Phase [#{phase.inspect}]\n"
            message += "PhaseScore [#{@phase_score.inspect}]"
            logger.error message
            authorize!(:gradebook, assignment)  # raise unauthorized error
          end
        end

      end
    end
  end
end
