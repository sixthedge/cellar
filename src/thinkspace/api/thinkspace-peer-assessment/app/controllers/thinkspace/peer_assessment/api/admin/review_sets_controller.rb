module Thinkspace; module PeerAssessment; module Api; module Admin;
  # # admin/review_sets
  # - Type: **Controller**
  # - Engine: **thinkspace-peer-assessment**
  class ReviewSetsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
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
      controller_render(@review_set)
    end

    def unignore
      access_denied_state_error :unignore unless @review_set.may_unignore?
      @review_set.transaction do
        @review_set.unignore!
      end
      controller_render(@review_set)
    end

    def notify
      message = params[:notification]
      Thinkspace::PeerAssessment::AssessmentMailer.notify_review_set_ownerable(@review_set, message).deliver_now
      controller_render(@review_set)
    end

    # ## Private
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
