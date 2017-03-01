module Thinkspace; module ReadinessAssurance; module PhaseActions; module Helpers; module Handler; module Records

  def assessment; @assessment ||= (processor.action_options[:assessment] || processor.find_componentables(assessment_class).first); end

  def next_trat_phase
    @next_trat_phase ||= begin
      next_phases     = processor.next_phases(phase).accessible_by(current_ability, :read)
      next_assessment = assessment_class.authable_trats(next_phases).first
      next_assessment.blank? ? nil : next_assessment.authable
    end
  end

  # ###
  # ### Response Score Helpers.
  # ###

  def response(o=ownerable)
    @response ||= processor.action_options[:response] ||
      (
        assessment.thinkspace_readiness_assurance_responses.find_by(ownerable: o) ||
        assessment.find_or_create_response(o, processor.current_user)
      )
  end

  # ###
  # ### Assignment Helpers.
  # ###

  def set_assignment(a); @assignment = a; end

  def assignment; @assignment ||= phase.thinkspace_casespace_assignment; end

  def assignment_ownerable_rooms(ownerables)
    ownerables.map {|ownerable| room_with_ownerable(assignment, ownerable)}
  end

  def assignment_admin_room; room_for(assignment, 'admin'); end

  def assignment_phases; assignment.thinkspace_casespace_phases.accessible_by(current_ability, :read); end

  # ###
  # ### Model Classes.
  # ###

  def assessment_class;          ::Thinkspace::ReadinessAssurance::Assessment; end
  def server_event_record_class; ::Thinkspace::PubSub::ServerEvent::Record; end
  def processor_class;           ::Thinkspace::Casespace::PhaseActions::Processor; end
  def team_class;                ::Thinkspace::Team::Team; end

end; end; end; end; end; end
