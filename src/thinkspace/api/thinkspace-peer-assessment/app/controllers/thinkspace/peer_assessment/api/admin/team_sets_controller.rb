module Thinkspace
  module PeerAssessment
    module Api
      module Admin
        class TeamSetsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_serializer_options
          before_action :set_state_error_variables

          include Thinkspace::PeerAssessment::Concerns::StateErrors

          def approve
            access_denied_state_error :approve unless @team_set.may_approve?
            @team_set.transaction do
              @team_set.approve!
            end
            controller_render(@team_set)
          end

          def unapprove
            access_denied_state_error :approve unless @team_set.may_unapprove?
            @team_set.transaction do
              @team_set.unapprove!
            end
            controller_render(@team_set)
          end

          def approve_all
            access_denied_state_error :approve unless @team_set.may_approve_all?
            @team_set.transaction do
              @team_set.approve_all!
            end
            controller_render(@team_set)
          end

          def unapprove_all
            access_denied_state_error :approve unless @team_set.may_unapprove_all?
            @team_set.transaction do
              @team_set.unapprove_all!
            end
            controller_render(@team_set)
          end

          private

          def authorize_authable
            authorize! :update, @team_set.authable
          end

          def set_state_error_variables
            @model        = @team_set
            @model_name   = 'a team set'
            @model_class  = @model.class.name
          end

        end
      end
    end
  end
end
