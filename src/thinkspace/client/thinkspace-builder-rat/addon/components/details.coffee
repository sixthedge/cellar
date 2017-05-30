import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ## Services
  # - `thinkspace-builder-pe/builder`
  builder: ember.inject.service()

  step:    ember.computed.reads 'builder.current_step'

  # ## Actions
  actions:
    next_step: -> @get('builder').transition_to_next_step(save: true, validation: true)
    exit: ->      @get('builder').transition_to_cases_show()
    