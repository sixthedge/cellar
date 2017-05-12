import ember         from 'ember'
import base          from 'thinkspace-base/components/base'

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

  question_items: ember.computed.reads 'step.trat_question_items'

  has_questions: ember.computed.notEmpty 'question_items'

  display_questions: ember.computed.not 'sync_assessments'
  sync_checked:      ember.computed.reads 'sync_assessments'

  actions:
    create: ->
      manager = @get('manager')
      manager.add_question_item(@get('type'))

    toggle_assessment_sync: (val) -> 
      ## Translates the value passed by the 'common/checkbox' component from string to boolean
      val = if val=='true' then false else true
      @sendAction('toggle_assessment_sync', val)