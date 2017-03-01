module Thinkspace; module ReadinessAssurance; module ProgressReports
class Base
  attr_reader :assessment, :authable, :ownerables, :responses

  def initialize(assessment)
    @assessment = assessment
    @authable   = assessment.authable
    set_ownerables_and_responses
  end

  def set_ownerables_and_responses
    @completed_ownerables = get_completed_ownerables
    @all_ownerables       = get_all_ownerables
    @responses            = get_responses
  end

  # ### Setters - set instance variables to be used OO.
  def get_completed_ownerables; irat? ? completed_users : completed_teams; end
  def get_all_ownerables; irat? ? all_users : all_teams; end
  def get_responses; irat? ? completed_irat_responses : completed_trat_responses; end

  # ### Assessment
  def answer_for_question_id(id);   @assessment.answer_for_question_id(id); end
  def order_for_question_id(id);    @assessment.order_for_question_id(id); end
  def choices_for_question_id(id);  @assessment.choices_for_question_id(id); end
  def question_for_question_id(id); @assessment.question_for_question_id(id); end
  def label_for_choice_for_question_id(id, choice); @assessment.label_for_choice_for_question_id(id, choice); end
  def order_for_choice_for_question_id(id, choice); @assessment.order_for_choice_for_question_id(id, choice); end
  
  def irat?; @assessment.irat?; end
  def trat?; @assessment.trat?; end
  def ifat?; @assessment.ifat?; end

  # ### Responses
  def completed_irat_responses
    @assessment.thinkspace_readiness_assurance_responses.scope_by_ownerables(@completed_ownerables)
  end

  def completed_trat_responses
    @assessment.thinkspace_readiness_assurance_responses.scope_by_ownerables(@completed_ownerables)
  end

  # ### Ownerables
  def all_users; @authable.get_space.thinkspace_common_users.scope_read; end
  def all_teams; @authable.thinkspace_casespace_assignment.thinkspace_team_teams; end

  # TODO: This only accounts for phase state, is that okay?  e.g. no state on Response.
  def completed_ownerables_for_class(klass)
    # ids = phase_state_class.where(thinkspace_casespace_phase: authable, ownerable_type: klass, current_state: :completed).pluck(:ownerable_id)

    # TODO: SCOPE BACK TO COMPLETED ONLY WHEN DONE WITH TESTING!
    ids = phase_state_class.where(thinkspace_casespace_phase: @authable, ownerable_type: klass).pluck(:ownerable_id)
    klass.where(id: ids)
  end

  def completed_users; completed_ownerables_for_class(user_class); end
  def completed_teams; completed_ownerables_for_class(team_class); end

  # ### Percentage helpers
  def percentages_from_decimal(decimal)
    rounded    = percentage_round_from_decimal(decimal)
    HashWithIndifferentAccess.new(decimal: decimal, rounded: rounded)
  end
  def percentage_round_from_decimal(decimal); (decimal.to_f * 100.0).round(2); end

  # ### Report/results helpers
  def report_average
    return 0.0 if @responses.empty?
    total_score = @responses.pluck(:score).inject(0.0) { |sum, x| sum + x.to_f }
    (total_score / responses_count).round(2).to_f
  end

  def flatten_results
    # Using a Hash for faster processing by key reference than [].find.
    # => Could refactor out `parse_json_to_results` to use an array if wanted at perf cost.
    a = Array.new
    @results.each { |id, value| a.push(value) }
    a
  end
  
  # ### Helpers
  def response_ids; @responses.pluck(:id); end
  def responses_count; @responses.count; end
  def all_ownerables_count; @all_ownerables.count; end
  def completed_ownerables_count; @completed_ownerables.count; end

  # ### Classes
  def phase_state_class; Thinkspace::Casespace::PhaseState; end
  def team_class; Thinkspace::Team::Team; end
  def user_class; Thinkspace::Common::User; end

end; end; end; end