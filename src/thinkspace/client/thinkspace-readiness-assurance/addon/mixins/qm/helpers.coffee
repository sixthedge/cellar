import ember       from 'ember'
import totem_error from 'totem/error'

export default ember.Mixin.create

  current_user_full_name: -> @rm.current_user_full_name()

  is_true_or_false: (val) -> val == true or val == false

  is_function: (fn) -> typeof(fn) == 'function'
  is_object: (obj)  -> obj and typeof(obj) == 'object'
  is_hash: (obj)    -> @is_object(obj) and not ember.isArray(obj)

  is_active:   (obj) -> not @is_inactive(obj)
  is_inactive: (obj) ->
    return true unless obj
    obj.isDestroyed or obj.isDestroying

  debug: ->
    console.warn @
    console.info 'answer_id    :', @get('answer_id')
    console.info 'justification:', @get('justification')
    console.info 'choices      :', @choices
    console.info 'qid          :', @qid
    console.info 'question     :', @question

  error: (args...) ->
    message = args.shift() or ''
    console.error message, args if ember.isPresent(args)
    totem_error.throw @, message

  toString: -> 'ReadinessAssuranceQuestionManager:' + ember.guidFor(@)
