module Thinkspace; module Authorization
class ThinkspacePeerAssessment < ::Totem::Settings.authorization.platforms.thinkspace.cancan.classes.ability_engine

  def process; call_private_methods; end

  private

  def peer_assessment
    assessment          = Thinkspace::PeerAssessment::Assessment
    review_set          = Thinkspace::PeerAssessment::ReviewSet
    team_set            = Thinkspace::PeerAssessment::TeamSet
    review              = Thinkspace::PeerAssessment::Review
    overview            = Thinkspace::PeerAssessment::Overview
    assessment_template = Thinkspace::PeerAssessment::AssessmentTemplate
    can [:read, :user_templates, :create], assessment_template
    can [:read, :fetch], assessment
    can [:read, :submit], review_set
    can [:crud], review
    can [:read], overview
    return unless admin?
    can [:approve, :teams, :review_sets, :team_sets, :update, :activate, :progress_report, :approve_team_sets], assessment 
    can [:approve, :unapprove], review
    can [:ignore, :unignore, :unlock, :notify], review_set
    can [:approve, :unapprove, :approve_all, :unapprove_all, :read], team_set
    can [:update], overview
  end

end; end; end
