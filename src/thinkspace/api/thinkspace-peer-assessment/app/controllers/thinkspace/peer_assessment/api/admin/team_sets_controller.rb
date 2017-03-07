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
            create_review_sets
            access_denied_state_error :approve unless @team_set.may_approve?
            @team_set.transaction do
              @team_set.approve!
            end
            controller_render(@team_set)
          end

          def unapprove
            create_review_sets
            access_denied_state_error :approve unless @team_set.may_unapprove?
            @team_set.transaction do
              @team_set.unapprove!
            end
            controller_render(@team_set)
          end

          # def approve_all
          #   create_review_sets
          #   access_denied_state_error :approve unless @team_set.may_approve_all?
          #   @team_set.transaction do
          #     @team_set.approve!
          #   end
          #   controller_render(@team_set)
          # end

          # def unapprove_all
          #   create_review_sets
          #   access_denied_state_error :approve unless @team_set.may_unapprove_all?
          #   @team_set.transaction do
          #     @team_set.unapprove!
          #   end
          #   controller_render(@team_set)
          # end

          def show
            create_review_sets
            controller_render(@team_set)
          end

          private

          def create_review_sets
            @team_set.thinkspace_team_team.thinkspace_common_users.each do |user|
              review_set = Thinkspace::PeerAssessment::ReviewSet.find_or_create_by(ownerable: user, team_set_id: @team_set.id)
              review_set.create_reviews
            end
          end

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
