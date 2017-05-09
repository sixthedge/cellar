import ember from 'ember'
import util  from 'totem/util'

export default ember.Mixin.create

  current_user_full_name: -> @rm.current_user_full_name()

  is_function:      (fn)  -> util.is_function(fn)
  is_hash:          (obj) -> util.is_hash(obj)
  is_true_or_false: (val) -> util.is_true_or_false(val)
  is_active:        (obj) -> not @is_inactive(obj)
  is_inactive:      (obj) -> util.is_destroyed(obj)

  error: (args...) -> util.error(args...)

  debug: ->
    console.warn @
    console.info 'answer_id    :', @get('answer_id')
    console.info 'justification:', @get('justification')
    console.info 'choices      :', @choices
    console.info 'qid          :', @qid
    console.info 'question     :', @question

  toString: -> 'ReadinessAssuranceQuestionManager:' + ember.guidFor(@)
