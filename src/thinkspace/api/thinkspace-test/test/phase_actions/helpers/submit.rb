module Test::PhaseActions::Helpers::Submit
extend ActiveSupport::Concern
included do

  def pap
    can_update = get_let_value(:can_update) || false
    debug      = get_let_value(:debug) || false
    @pap ||= phase_action_processor_class.new(current_phase, current_user, action: :submit, can_update: can_update, debug: debug)
  end

  def validation
    {phase_score_validation: {numericality: {greater_than_or_equal_to: 1, less_than_or_equal_to: 5}}}
  end

  def set_submit_settings(settings)
    current_phase.settings = {actions: {submit: settings}}
    current_phase.save
  end

  def assert_submit_phase_state(action_state, state=nil)
    state ||= action_state
    set_submit_settings(state: action_state)
    process_action
    assert_phase_state(state)
  end

  def assert_submit_phase_score(score, options={})
    if options.blank?
      settings = {auto_score: true}
    else
      settings = {auto_score: options}
    end
    set_submit_settings(settings)
    process_action
    assert_phase_score(score)
  end

end; end
