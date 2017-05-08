import ember         from 'ember'
import base          from 'thinkspace-base/components/base'
import question_item from 'thinkspace-builder-rat/items/question'


###
# # irat.coffee
- Type: **Component**
- Package: **ethinkspace-builder-rat**
###
export default base.extend
  # classNameBindings: ['has_questions::is-readonly']

  model: null
  type:  'trat'

  manager: ember.inject.service()

  question_items: ember.computed 'step.trat_assessment.questions_with_answers.@each', ->
    items = @get('step.trat_assessment.questions_with_answers')
    if ember.isPresent(items)
      @create_question_item(item) for item in items

  has_questions: ember.computed.notEmpty 'question_items'

  display_questions: ember.computed.not 'sync_assessments'
  sync_checked:      ember.computed.reads 'sync_assessments'

  create_question_item: (item) ->
    question_item.create
      model:      item
      assessment: @get('model')
      trat:       @get('type')
      ## Container necessary if we want to inject the manager service
      container:  @container

  actions:
    create: ->
      manager = @get('manager')
      manager.add_question_item(@get('type'))

    toggle_assessment_sync: (val) -> 
      val = if val=='true' then false else true
      console.log('[trat.coffee] calling toggle_assessmetn_sync with value ', val)
      @sendAction('toggle_assessment_sync', val)