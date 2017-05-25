import ember         from 'ember'
import base          from 'thinkspace-base/components/base'

###
# # irat.coffee
- Type: **Component**
- Package: **ethinkspace-builder-rat**
###
export default base.extend

  model: null
  type:  'irat'

  manager: ember.inject.service()

  question_items: ember.computed.reads 'step.irat_question_items'
  has_questions:  ember.computed.notEmpty 'question_items'

  actions:
    create: ->
      manager = @get('manager')
      manager.add_question_item(@get('type'))