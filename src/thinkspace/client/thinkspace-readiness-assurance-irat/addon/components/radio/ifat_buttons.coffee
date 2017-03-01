import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName:           'div'
  classNameBindings: ['no_errors::ts-ra_error']

  willInsertElement: -> @qm.set_question_disabled_on() if @qm.get('readonly')

  has_selections: false
  is_correct:     false

  score: ember.computed 'qm.response_updated', ->
    qid            = @qm.qid
    has_selections = ember.isPresent(@get("qm.response.userdata.attempt_values.#{qid}"))
    is_correct     = @get("qm.response.userdata.question_correct.#{qid}")
    @setProperties(has_selections: has_selections, is_correct: is_correct)
    @get("qm.response.userdata.question_scores.#{@qm.qid}")

  actions:
    select: (id) -> @sendAction 'select', id
