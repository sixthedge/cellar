import ember from 'ember'

export default ember.Object.extend
  button_id:        ember.computed.reads 'choice.id'
  button_label:     ember.computed.reads 'choice.label'
  
  is_correct:       false

  get_answer_id: -> @get('qm.answer_id')
  get_button_id: -> @get('button_id')

  # # Accessibility
  # ## Properties
  delayed:  true # Do not auto fire `click` on arrow keys.

  # ## Computed properties
  checked:  ember.computed.reads 'is_selected'
  value:    ember.computed.reads 'choice.id'
  label:    ember.computed.reads 'choice.label'
  disabled: ember.computed.or 'qm.readonly', 'qm.answers_disabled', 'has_been_selected'

  classes: ember.computed 'is_correct', 'is_selected', 'has_been_selected', ->
    has_been_selected = @get('has_been_selected')
    return unless has_been_selected
    css         = []
    is_selected = @get('is_selected')
    is_correct  = @get('is_correct')
    css.pushObject('is-selected')  if is_selected
    css.pushObject('is-correct')   if is_correct
    css.pushObject('is-incorrect') if !is_correct
    css.join(' ')

  is_selected: ember.computed 'qm.answer_id', ->
    aid = @get_answer_id()
    bid = @get_button_id()
    bid and bid == aid

  has_been_selected: ember.computed 'qm.response_updated', ->
    qid            = @qm.qid
    attempt_values = @get("qm.response.userdata.attempt_values.#{qid}")
    return false if ember.isBlank(attempt_values)
    bid = @get_button_id()
    return false unless attempt_values.contains(bid)
    qid_is_correct = @get("qm.response.userdata.question_correct.#{qid}")
    correct_answer = @get("qm.response.userdata.correct_answer.#{qid}")
    is_correct     = qid_is_correct and bid == correct_answer
    @set 'is_correct', is_correct
    @qm.set_question_disabled_on() if is_correct
    true