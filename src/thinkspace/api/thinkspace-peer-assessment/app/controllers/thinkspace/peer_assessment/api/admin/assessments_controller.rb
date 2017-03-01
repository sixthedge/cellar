module Thinkspace
  module PeerAssessment
    module Api
      module Admin
        class AssessmentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_serializer_options
          before_action :authorize_authable
          before_action :set_state_error_variables

          include Thinkspace::PeerAssessment::Concerns::StateErrors

          def update
            access_denied_state_error :update if @assessment.active?
            @assessment.value = params_root[:value]
            @assessment.assessment_template_id = params_association_id(:assessment_template_id)
            # if @assessment.save
            #   controller_render_no_content
            # else
            @assessment.save ? controller_render(@assessment) : controller_render_error(@assessment)
            # end
          end

          def activate
            access_denied_state_error :activate unless @assessment.may_activate?
            phase = @assessment.authable
            teams = phase.thinkspace_team_teams
            access_denied "No teams are assigned to phase [#{phase.id}].", 'There are no teams assigned to this phase.  Please assign a team and try again.' if teams.blank?
            @assessment.activate!
            controller_render(@assessment)
          end

          def approve
            access_denied_state_error :approve unless @assessment.may_approve?
            @assessment.approve!
            controller_render(@assessment)
          end

          def teams
            teams = Thinkspace::Team::Team.scope_by_teamables(@assessment.authable)
            controller_render(teams)
          end

          def review_sets
            team_id     = params[:team_id]
            team        = Thinkspace::Team::Team.find_by(id: team_id)
            authorize! :update, team.authable
            team_set    = Thinkspace::PeerAssessment::TeamSet.find_or_create_by(team_id: team_id, assessment_id: @assessment.id)
            review_sets = team_set.thinkspace_peer_assessment_review_sets
            controller_render(review_sets)
          end

          def team_sets
            team_ids          = Thinkspace::Team::Team.scope_by_teamables(@assessment.authable).pluck(:id)
            assessment_id     = @assessment.id
            team_sets         = Thinkspace::PeerAssessment::TeamSet.where(assessment_id: assessment_id, team_id: team_ids)
            existing_team_ids = team_sets.pluck(:team_id)
            create_team_ids   = team_ids - existing_team_ids
            create_team_ids.each { |id| Thinkspace::PeerAssessment::TeamSet.create(assessment_id: assessment_id, team_id: id) }
            team_sets.reload unless create_team_ids.empty?
            controller_render(team_sets)
          end

          private

          def access_denied(message, user_message='')
            raise_access_denied_exception(message, self.action_name.to_sym, @user || controller_model_class_name, user_message: user_message)
          end

          def authorize_authable
            authorize! :update, @assessment.authable
          end

          def set_state_error_variables
            @model        = @assessment
            @model_name   = 'an assessment'
            @model_class  = @model.class.name
          end

        end
      end
    end
  end
end
