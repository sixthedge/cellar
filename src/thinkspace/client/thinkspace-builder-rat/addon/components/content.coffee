import ember         from 'ember'
import base          from 'thinkspace-base/components/base'

export default base.extend
  # ## Services
  # - `thinkspace-builder-pe/builder`
  builder: ember.inject.service()

  step: ember.computed.reads 'builder.current_step'

  # ## Actions
  actions:
    prev_step: -> @get('builder').transition_to_prev_step()
    next_step: -> @get('builder').transition_to_next_step()
    exit: ->      @get('builder').transition_to_cases_show()

    toggle_assessment_sync: -> @get('step').toggle_assessment_sync()