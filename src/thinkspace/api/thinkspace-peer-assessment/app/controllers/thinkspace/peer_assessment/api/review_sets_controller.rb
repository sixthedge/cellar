module Thinkspace
  module PeerAssessment
    module Api
      class ReviewSetsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
        load_and_authorize_resource class: totem_controller_model_class
        totem_action_authorize!
        totem_action_serializer_options
        before_action :authorize_review_set

        def submit
          @review_set.submit! if @review_set.may_submit?
          phase_state = @review_set.complete_phase_for_ownerable
          json = controller_as_json(@review_set)
          json['thinkspace/casespace/phase_states'] = [phase_state]
          controller_render_json(json)
        end 

        private

        def authorize_review_set
          access_denied "Cannot submit a review set you do not own." unless current_user == @review_set.ownerable
          access_denied "Cannot submit a review_set that is already in an approved-type state.", user_message: "You cannot submit assessments that have been already submitted or approved by an instructor." if @review_set.approved? or @review_set.submitted?
        end

        def access_denied(message, options={})
          raise_access_denied_exception(message, totem_action_authorize.action, @review_set, options)
        end

      end
    end
  end
end
