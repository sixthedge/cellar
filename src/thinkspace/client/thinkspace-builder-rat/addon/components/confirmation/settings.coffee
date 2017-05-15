import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # settings.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend
  builder: ember.inject.service()

  model: ember.computed.reads 'builder.model'
  step:  ember.computed.reads 'builder.step_settings'

  phases: ember.computed.reads 'step.model.active_phases'