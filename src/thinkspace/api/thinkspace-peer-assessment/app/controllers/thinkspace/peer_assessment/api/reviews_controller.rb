module Thinkspace
  module PeerAssessment
    module Api
      class ReviewsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize! allow_blank_associations: { create: [:review_set_id] }
        totem_action_serializer_options
        before_action :find_review_set, only: [:create, :update]
        #before_action :authorize_ownerable, only: [:update]

        def create
          reviewable_type         = params_root[:reviewable_type]
          reviewable_id           = params_root[:reviewable_id]
          access_denied "Cannot create a review without a reviewable_type." unless reviewable_type.present?
          access_denied "Cannot create a review without a reviewable_id." unless reviewable_id.present?
          reviewable_type = reviewable_type.classify
          authorize_reviewable(reviewable_type, reviewable_id)
          @review.reviewable_type = reviewable_type
          @review.reviewable_id   = reviewable_id
          @review.value           = params_root[:value]
          @review.review_set_id   = @review_set.id
          controller_save_record(@review)
        end

        def update
          can_update_authable = current_ability.can? :update, @review.authable
          review_set          = @review.thinkspace_peer_assessment_review_set
          case 
          when @review.sent?
            access_denied_state_invalid
          when (@review.submitted? && review_set.submitted?) && !can_update_authable
            access_denied_state_invalid
          when @review.approved? && !can_update_authable
            access_denied_state_invalid
          when @review.approved? && can_update_authable
            process_updates
          else
            process_updates
          end
        end

        private

        def process_updates
          @review.value = params_root[:value]
          controller_save_record(@review)
        end

        def access_denied_state_invalid
          access_denied 'Review is approved and cannot be updated.', user_message: 'You cannot update a submitted or approved assessment.'
        end

        def find_review_set
          review_set_id = params_association_id(:review_set_id)
          @review_set   = Thinkspace::PeerAssessment::ReviewSet.find_by(id: review_set_id)
        end

        def authorize_ownerable
          ownerable  = totem_action_authorize.params_ownerable
          authable   = @review.authable # Phase
          access_denied "Ownerable cannot update the review." unless current_ability.can?(:update, authable) or @review.ownerable == ownerable
        end

        def authorize_reviewable(type, id)
          klass = type.safe_constantize
          access_denied "Cannot constantize reviewable_type [#{type}]" unless klass.present?
          reviewable = klass.find(id)
          access_denied "Cannot valdiate reviewable without a review set" unless @review_set.present?
          ownerable  = totem_action_authorize.params_ownerable
          access_denied "Ownerable is not the owner of review set [#{@review_set.inspect}]" unless ownerable == @review_set.ownerable
          team_set   = @review_set.thinkspace_peer_assessment_team_set
          access_denied "Cannot validate reviewable without a valid team set." unless team_set.present?
          team       = team_set.thinkspace_team_team
          access_denied "Cannot validate reviewable without a valid team." unless team.present?
          assessment = team_set.thinkspace_peer_assessment_assessment
          access_denied "Cannot validate reviewable without a valid assessment." unless assessment.present?
          access_denied "Reviewable is not on current user's team." unless Thinkspace::Team::Team.users_on_teams?(assessment.authable, reviewable, team)
        end

        def access_denied(message, options={})
          raise_access_denied_exception(message, totem_action_authorize.action, @review, options)
        end


      end
    end
  end
end
