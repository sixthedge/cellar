module Thinkspace
  module PeerAssessment
    module Api
      module Admin
        class ReviewSetsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_serializer_options
          before_action :set_state_error_variables

          include Thinkspace::PeerAssessment::Concerns::StateErrors

          def approve
            access_denied_state_error :approve unless @review_set.may_approve?
            @review_set.approve_all!
            controller_render(@review_set)
          end

          def unapprove
            access_denied_state_error :unapprove unless @review_set.may_unapprove?
            @review_set.transaction do
              @review_set.unapprove_all!
            end
            controller_render(@review_set)
          end

          def notify
            message = params[:notification]
            Thinkspace::PeerAssessment::AssessmentMailer.notify_review_set_ownerable(@review_set, message).deliver_now
            controller_render(@review_set)
          end

          private

          def authorize_authable
            authorize! :update, @review_set.authable
          end

          def set_state_error_variables
            @model        = @review_set
            @model_name   = 'a review set'
            @model_class  = @model.class.name
          end

        end
      end
    end
  end
end
