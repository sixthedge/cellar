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

  step:    ember.computed.reads 'builder.step_confirmation'

  # ## Actions
  actions:
    set_loading:   (type) -> @get('step').set_loading(type)
    reset_loading: (type) -> @get('step').reset_loading(type)

    prev_step: -> @get('builder').transition_to_prev_step()
    exit: -> @get('builder').transition_to_cases_show()

