import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # details.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend
  builder: ember.inject.service()

  step:    ember.computed.reads 'builder.step_details'

  actions:
    next_step: -> @get('builder').transition_to_next_step(save: true, validate: true)
    exit: ->      @get('builder').transition_to_cases_show()
