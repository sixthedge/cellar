module Thinkspace; module PeerAssessment; module Api; module Admin
  class OverviewsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
    # Thinkspace::PeerAssessment::Api::Admin::OverviewsController
    # ---
    load_and_authorize_resource class: totem_controller_model_class
    totem_action_serializer_options
    totem_action_authorize!

    # ## Endpoints
    # - `update`
    def update
      authorize! :update, @overview.authable
      assessment_id = params_root[:assessment_id]
      assessment = Thinkspace::PeerAssessment::Assessment.find_by(id: assessment_id)
      access_denied("Assessment [#{assessment_id}] cannot be found.", :update) unless assessment.present?
      authorize! :update, assessment.authable
      @overview.assessment_id = assessment_id
      controller_save_record(@overview)
    end

    # ## Private
    private

    def access_denied(message, action=:create, records=nil)
      raise_access_denied_exception(message, action, records)
    end

  end
end; end; end; end