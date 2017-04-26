import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # confirmation.coffee
- Type: **Component**
- Package: **thinkspace-builder-rat**
###
export default base.extend
  # ## Services
  # - `thinkspace-builder-rat/builder`
  builder: ember.inject.service()

  step:    ember.computed.reads 'builder.current_step'

  # ## Actions
  actions:
    prev_step: -> @get('builder').transition_to_prev_step()
    exit: -> @get('builder').transition_to_cases_show()