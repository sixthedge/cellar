module Thinkspace
  module PeerAssessment
    module Api
      module Admin
        class ReviewsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_serializer_options
          before_action :set_state_error_variables

          include Thinkspace::PeerAssessment::Concerns::StateErrors

          def approve
            access_denied_state_error :approve unless @review.may_approve?
            assessment = @review.get_assessment
            @review.approve!
            controller_render(@review)
          end

          def unapprove
            access_denied_state_error :unapprove unless @review.may_unapprove?
            @review.transaction do
              unapprove_review_set
              unapprove_team_set
              @review.unapprove!
            end
            controller_render(@review)
          end

          private

          def authorize_authable
            authorize! :update, @review.authable
          end

          def unapprove_review_set
            review_set = @review.get_review_set
            review_set.unapprove! if review_set.may_unapprove?
          end

          def unapprove_team_set
            team_set = @review.get_team_set
            team_set.unapprove! if team_set.may_unapprove?
          end

          def set_state_error_variables
            @model        = @review
            @model_name   = 'a review'
            @model_class  = @model.class.name
          end
          
        end
      end
    end
  end
end
