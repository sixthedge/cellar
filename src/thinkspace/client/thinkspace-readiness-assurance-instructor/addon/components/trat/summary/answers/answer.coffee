import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  qnumber:  ember.computed.reads 'qms.firstObject.qn'
  qid:      ember.computed.reads 'qms.firstObject.qid'
  question: ember.computed.reads 'qms.firstObject.question'

  choice_counts: null

  willInsertElement: ->
    qm.register_change_callback(@, 'handle_question_change') for qm in @qms
    @set_choice_counts()

  set_choice_counts: ->
    qid        = @get('qid')
    question   = @assessment.get_question_by_id(qid)
    choices    = question.choices
    correct_id = @get("assessment.answers.correct.#{qid}")
    results    = []
    for choice in choices
      cid     = choice.id
      label   = choice.label
      qms     = @qms.filterBy 'answer_id', cid
      count   = if ember.isPresent(qms) then qms.length else 0
      correct = cid == correct_id
      results.push {label, count, correct}
    @set_max_count(results)
    @set 'choice_counts', results

  set_max_count: (results) ->
    counts = results.mapBy 'count'
    max    = counts.sort().get('lastObject')
    return unless max > 0
    for result in results
      result.max = true if result.count == max

  handle_question_change: (qm, key) -> @set_choice_counts()
