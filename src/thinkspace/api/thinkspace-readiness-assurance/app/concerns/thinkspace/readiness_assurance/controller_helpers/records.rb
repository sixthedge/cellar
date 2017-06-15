module Thinkspace; module ReadinessAssurance; module ControllerHelpers; module Records

  def assignment
    @assignment ||= begin
      access_denied "Authable is blank." if authable.blank?
      access_denied "Cannot read authable.", authable  unless can?(:read, authable)
      a = authable.is_a?(phase_class) ? authable.thinkspace_casespace_assignment : authable
      access_denied "Cannot read assignment.", a  unless can?(:read, a)
      a
    end
  end

  def assignment_phases; assignment.thinkspace_casespace_phases.accessible_by(current_ability, :read); end

  def team?(o=ownerable); team_ownerable?(o); end
  def team_ownerable?(record); record.is_a?(team_class); end

  def phase_teams(phase)
    p_teams = phase.thinkspace_team_teams.order(:title)
    a_teams = phase.thinkspace_casespace_assignment.thinkspace_team_teams.order(:title)
    p_teams + a_teams
  end

  def irat?; @assessment.irat?; end
  def trat?; @assessment.trat?; end

  def set_irat_assessment; @assessment = get_irat_assessment; end

  def set_trat_assessment; @assessment = get_trat_assessment; end

  def get_irat_assessment; assessment_class.authable_irats(assignment_phases).first || access_denied("IRAT assessment not found."); end
  def get_trat_assessment; assessment_class.authable_trats(assignment_phases).first || access_denied("TRAT assessment not found."); end

  def get_irat_phase; get_assessment_phase(get_irat_assessment) || access_denied("IRAT phase not found."); end
  def get_trat_phase; get_assessment_phase(get_trat_assessment) || access_denied("TRAT phase not found."); end

  def get_assessment_phase(assessment); assessment.blank? ? nil : assessment.authable; end

  # ###
  # ### Classes.
  # ###

  def assessment_class;   Thinkspace::ReadinessAssurance::Assessment; end
  def response_class;     Thinkspace::ReadinessAssurance::Response; end
  def user_class;         Thinkspace::Common::User; end
  def phase_class;        Thinkspace::Casespace::Phase; end
  def team_class;         Thinkspace::Team::Team; end

end; end; end; end
