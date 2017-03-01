import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  phase_manager: ember.inject.service()

  current_phase: ember.computed.reads 'thinkspace.current_phase'

  willInsertElement: ->
    phase = @get('model')
    map   = @get('phase_manager.map')
    if ember.isPresent(map)
      phase_states = map.get_ownerable_phase_states(phase)
      @set 'phase_states', phase_states
    else
      @set 'phase_states', new Array

  actions:
    save_phase_score: (phase, score) ->  @sendAction 'save', phase, score  # pass-through to phase.coffee
