import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  phase_manager: ember.inject.service()

  init_base: ->
    @pm   = @get('phase_manager')
    @pmap = @get('phase_manager.map')

  phase_states: ember.computed ->
    phase = @get('model')
    if @pm.has_active_addons()
      @pmap.get_current_ownerable_phase_states(phase)
    else
      @pmap.get_current_user_phase_states(phase)
