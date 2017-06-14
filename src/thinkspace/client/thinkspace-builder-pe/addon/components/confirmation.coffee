import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # confirmation.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend
  # ## Services
  # - `thinkspace-builder-pe/builder`
  builder: ember.inject.service()

  step:       ember.computed.reads 'builder.current_step'
  steps:      ember.computed.reads 'builder.steps'
  changesets: ember.computed.mapBy 'steps', 'changeset'

  # ## Actions
  actions:
    prev_step: -> @get('builder').transition_to_prev_step()
    exit: -> @get('builder').transition_to_cases_show()

