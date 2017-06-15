import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # content.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend
  builder: ember.inject.service()
  manager: ember.inject.service()

  model:      ember.computed.reads 'builder.model'
  step:       ember.computed.reads 'builder.step_content'

  trat_assessment:  ember.computed.reads 'manager.trat'
  irat_assessment:  ember.computed.reads 'manager.irat'
  sync_assessments: ember.computed.reads 'model.sync_rat_assessments'

  init_base: ->
    @get('step').initialize()
  