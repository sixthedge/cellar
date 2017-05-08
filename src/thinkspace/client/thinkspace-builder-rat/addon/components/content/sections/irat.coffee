import ember         from 'ember'
import base          from 'thinkspace-base/components/base'
import question_item from 'thinkspace-builder-rat/items/question'


###
# # irat.coffee
- Type: **Component**
- Package: **ethinkspace-builder-rat**
###
export default base.extend

  model: null
  type:  'irat'

  manager: ember.inject.service()

  question_items: ember.computed 'step.irat_assessment.questions_with_answers.@each', ->
    items = @get('step.irat_assessment.questions_with_answers')
    if ember.isPresent(items)
      @create_question_item(item) for item in items

  create_question_item: (item) ->
    question_item.create
      model:      item
      assessment: @get('model')
      type:       @get('type')
      ## Container necessary if we want to inject the manager service
      container:  @container

  actions:
    create: ->
      manager = @get('manager')
      manager.add_question_item(@get('type'))