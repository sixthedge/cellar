module Thinkspace; module PeerAssessment; module Api; module Admin;
  class AssessmentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
    # Thinkspace::PeerAssessment::Api::Admin::AssessmentsController
    # ---
    load_and_authorize_resource class: totem_controller_model_class
    totem_action_serializer_options
    before_action :authorize_authable
    before_action :set_state_error_variables

    include Thinkspace::PeerAssessment::Concerns::StateErrors

    # ## Endpoints
    # - `update`
    # - `activate`
    # - `approve`
    # - `approve_team_sets
    # - `teams`
    # - `review_sets`
    # - `team_sets`
    # - `progress_reports`
    def update
      access_denied_state_error :update if @assessment.active?
      puts '***************************PE UPDATE***************************'
      puts '***************************PE UPDATE***************************'
      puts '***************************PE UPDATE***************************'
      puts '***************************PE UPDATE***************************'
      puts '***************************PE UPDATE***************************'
      puts '***************************PE UPDATE***************************'
      puts '***************************PE UPDATE***************************'
      puts '***************************PE UPDATE***************************'
      puts '***************************PE UPDATE***************************'
      puts params_root
      
      if @assessment.has_reviews?
        if @assessment.transform.present?
          @assessment.transform = params_root[:transform]
        else
          puts 'not hitting this is it...'
          @assessment.transform = {
            value: params_root[:value],
            assessment_template_id: params_root[:assessment_template_id]
          }
        end
      else
        @assessment.value = params_root[:value]
      end
      @assessment.assessment_template_id = params_association_id(:assessment_template_id)
      @assessment.save ? controller_render(@assessment) : controller_render_error(@assessment)
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
      controller_render(@assessment.thinkspace_peer_assessment_team_sets)
    end

    def approve_team_sets
      @team_sets = @assessment.thinkspace_peer_assessment_team_sets
      @team_sets.scope_neutral.update_all(state: 'approved')
      Thinkspace::PeerAssessment::ReviewSet.where(team_set_id: @team_sets.pluck(:id)).scope_neutral.update_all(state: 'ignored')
      controller_render(@team_sets)
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
      team_sets = @assessment.get_or_create_team_sets()
      controller_render(team_sets)
    end

    def progress_report
      data = Thinkspace::PeerAssessment::ProgressReports::Assessment.new(@assessment).process
      controller_render_json(data) 
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
end; end; end; end;
