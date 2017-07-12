module Thinkspace; module PeerAssessment; module Api; module Admin;
  class ReviewSetsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
    # Thinkspace::PeerAssessment::Api::Admin::ReviewSetsController
    # ---
    load_and_authorize_resource class: totem_controller_model_class
    totem_action_serializer_options
    before_action :set_state_error_variables

    include Thinkspace::PeerAssessment::Concerns::StateErrors

    # ## Endpoints
    # - `ignore`
    # - `unlock`
    # - `unignore`
    # - `notify`
    def ignore
      access_denied_state_error :ignore unless @review_set.may_ignore?
      @review_set.ignore!
      controller_render(@review_set)
    end

    def unlock
      access_denied_state_error :unlock unless @review_set.may_unlock?
      @review_set.unlock!
      @review_set.unlock_phase_and_notify
      controller_render(@review_set)
    end

    def unignore
      access_denied_state_error :unignore unless @review_set.may_unignore?
      @review_set.transaction do
        @review_set.unignore!
      end
      controller_render(@review_set)
    end

    def complete
      access_denied_state_error :submit unless @review_set.may_submit?
      @review_set.submit!
      @review_set.complete_phase_for_ownerable
      controller_render(@review_set)
    end

    def remind
      Thinkspace::PeerAssessment::AssessmentMailer.notify_assessment_reminder(@review_set).deliver_now
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
end; end; end; end;
