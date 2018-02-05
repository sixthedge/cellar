import ember from 'ember'
import base  from 'thinkspace-base/components/base'
import ifat  from 'thinkspace-readiness-assurance-trat/choices/ifat'

export default base.extend
  # # Properties
  tagName:           'div'
  classNameBindings: ['no_errors::ts-ra_error']

  has_selections: false
  is_correct:     false

  value: ember.computed.reads 'qm.answer_id'

  # # Computed properties
  score: ember.computed 'qm.response_updated', ->
    qid            = @qm.qid
    has_selections = ember.isPresent(@get("qm.response.userdata.attempt_values.#{qid}"))
    is_correct     = @get("qm.response.userdata.question_correct.#{qid}")
    @setProperties(has_selections: has_selections, is_correct: is_correct)
    @get("qm.response.userdata.question_scores.#{@qm.qid}")

  # # Events
  init_base: -> @set_options()
  willInsertElement: -> @qm.set_question_disabled_on() if @qm.get('readonly')

  # # Helpers
  set_options: ->
    question = @get('qm.question')
    choices  = @get('qm.choices')
    objs = []
    choices.forEach (choice) =>
      obj = ifat.create
        qm:     @qm
        choice: choice
      objs.pushObject(obj)
    options  = 
      group:
        label: question
      choices: objs
    @set('options', options)

  value_is_answer_id: -> @get('value') == @get('qm.answer_id')

  actions:
    save:        ->
      return if @value_is_answer_id()
      @sendAction('select', @get('value'))
    select:      (id) -> @set('value', id)
