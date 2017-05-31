module Thinkspace; module PeerAssessment; module Api;
  class AssessmentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
    # Thinkspace::PeerAssessment::Api::AssessmentsController
    # ---
    load_and_authorize_resource class: totem_controller_model_class
    totem_action_authorize! except: [:fetch]
    totem_action_serializer_options

    # ## Endpoints
    # - `show`
    # - `view`
    # - `fetch`
    def show
      controller_render(@assessment)
    end

    def view
      # A student cannot view an assessment that is not active or approved.
      # access_denied "Assessment is already approved.", user_message: 'This assessment has already been sent by your instructor.' if @assessment.approved?
      
      if !(@assessment.active? || @assessment.approved?) && current_ability.cannot?(:update, @assessment.authable)
        access_denied "Assessment is not activated yet.", user_message: 'You cannot access this assessment yet, it has not been activated by your instructor.'
      end

      sub_action = totem_action_authorize.sub_action
      case sub_action
      when :teams
        teams
      when :team_set
        team_set
      when :review_sets
        review_sets
      when :overview
        overview
      else
        access_denied "Unknown assessment view sub action #{sub_action.inspect}"
      end
    end

    def fetch
      assignment_id = params[:assignment_id]
      assignment    = Thinkspace::Casespace::Assignment.find(assignment_id)
      phase_ids     = assignment.thinkspace_casespace_phases.scope_active.pluck(:id)
      assessments   = Thinkspace::PeerAssessment::Assessment.where(authable_type: 'Thinkspace::Casespace::Phase', authable_id: phase_ids).limit(1)
      assessments.empty? ? controller_render([]) : controller_render(assessments.first)
    end
    
    # ## Private
    private

    def teams
      serializer_options.authorize_action    :read_teammate, :commenterable, scope: :root # allow the `commenterable` user to be serialized

      ownerable  = totem_action_authorize.params_ownerable
      phase      = @assessment.authable
      assignment = phase.thinkspace_casespace_assignment
      teams      = Thinkspace::Team::Team.users_teams(phase, ownerable)
      teams      = Thinkspace::Team::Team.users_teams(assignment, ownerable) unless teams.present?
      access_denied "No teams found for ownerable.", user_message: "You are not assigned to a team for this phase." unless teams.present?
      team = teams.first
      user_ids  = team.thinkspace_common_users.pluck(:id)
      controller_render(team)
    end

    def team_set
      ownerable = totem_action_authorize.params_ownerable
      team_id   = params[:team_id]
      team      = Thinkspace::Team::Team.find(team_id)
      access_denied "Team is invalid or not assigned to correct teamable." unless team.present?
      phase = @assessment.authable
      assignment = phase.thinkspace_casespace_assignment
      access_denied "Ownerable is not a member of specified team" unless (Thinkspace::Team::Team.users_on_teams?(phase, ownerable, team) || Thinkspace::Team::Team.users_on_teams?(assignment, ownerable, team))
      team_set   = Thinkspace::PeerAssessment::TeamSet.find_or_create_by(team_id: team_id, assessment_id: @assessment.id)
      controller_render(team_set)
    end

    def review_sets
      ownerable = totem_action_authorize.params_ownerable
      team_id   = params[:team_id]
      team      = Thinkspace::Team::Team.find(team_id)
      access_denied "Team is invalid or not assigned to correct teamable." unless team.present?
      phase = @assessment.authable
      assignment = phase.thinkspace_casespace_assignment
      access_denied "Ownerable is not a member of specified team" unless (Thinkspace::Team::Team.users_on_teams?(phase, ownerable, team) || Thinkspace::Team::Team.users_on_teams?(assignment, ownerable, team))
      team_set   = Thinkspace::PeerAssessment::TeamSet.find_or_create_by(team_id: team_id, assessment_id: @assessment.id)
      review_set = Thinkspace::PeerAssessment::ReviewSet.find_or_create_by(ownerable: ownerable, team_set_id: team_set.id)
      review_set.create_reviews
      controller_render(review_set)
    end

    def overview
      ownerable  = totem_action_authorize.params_ownerable
      phase      = @assessment.authable
      teams      = Thinkspace::Team::Team.users_teams(phase, ownerable)
      access_denied "No teams found on phase for ownerable." unless teams.present?
      team      = teams.first
      access_denied "No team found on phase for ownerable." unless team.present?
      team_set =  Thinkspace::PeerAssessment::TeamSet.find_by(team_id: team.id, assessment_id: @assessment.id)
      access_denied "No team set found for team_id [#{team.id}] and assessment_id [#{@assessment.id}]" unless team_set.present?
      # Ownerable_type and ID needed because of: https://github.com/rails/rails/issues/16983
      review_sets = Thinkspace::PeerAssessment::ReviewSet.where(team_set_id: team_set.id, ownerable_type: ownerable.class.name).scope_where_not_ownerable_ids(ownerable).scope_submitted
      access_denied "No review sets found for team_set_id [#{team_set.id}]" unless review_sets.present?
      review_set_ids = review_sets.pluck(:id)
      reviews        = Thinkspace::PeerAssessment::Review.where(review_set_id: review_set_ids, reviewable: ownerable)
      json           = Thinkspace::PeerAssessment::Review.generate_anonymized_review_json(@assessment, reviews)
      controller_render_json(json)
    end

    def access_denied(message, options={})
      raise_access_denied_exception(message, totem_action_authorize.action, @assessment, options)
    end

  end
end; end; end;
