module Thinkspace; module PeerAssessment; module Api;
  # # review_sets
  # - Type: **Controller**
  # - Engine: **thinkspace-peer-assessment**
  class ReviewSetsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
    load_and_authorize_resource class: totem_controller_model_class
    totem_action_authorize!
    totem_action_serializer_options
    before_action :authorize_review_set

    # ## Endpoints
    # - `submit`
    def submit
      @review_set.submit! if @review_set.may_submit?
      phase_state = @review_set.complete_phase_for_ownerable
      json = controller_as_json(@review_set)
      json[:included] = []
      json[:included][0] = {
        attributes: phase_state.attributes,
        id: phase_state.id,
        type: 'thinkspace/casespace/phase_state'
      }
      controller_render_json(json)
    end 

    # ## Private
    private

    def authorize_review_set
      access_denied "Cannot submit a review set you do not own." unless current_user == @review_set.ownerable
      access_denied "Cannot submit a review_set that is already in an approved-type state.", user_message: "You cannot submit assessments that have been already submitted or ignored by an instructor." unless @review_set.may_submit?
    end

    def access_denied(message, options={})
      raise_access_denied_exception(message, totem_action_authorize.action, @review_set, options)
    end

  end
end; end; end;
