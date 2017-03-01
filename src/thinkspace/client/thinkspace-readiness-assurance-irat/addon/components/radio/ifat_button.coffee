import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  button_id:        ember.computed.reads 'choice.id'
  button_label:     ember.computed.reads 'choice.label'
  buttons_disabled: ember.computed.or 'qm.readonly', 'qm.answers_disabled'
  is_correct:       false

  get_answer_id: -> @get('qm.answer_id')
  get_button_id: -> @get('button_id')

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

  actions:
    select: ->
      return if @get('buttons_disabled')
      return if @get('has_been_selected')
      @sendAction 'select', @get_button_id()
