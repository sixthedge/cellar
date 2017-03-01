import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  phase_manager: ember.inject.service()

  phase_states: null
  selected:     null

  init_base: ->
    @pm       = @get('phase_manager')
    @pmap     = @get('phase_manager.map')
    phase     = @get('model')
    ownerable = @get_ownerable()
    phase.get(ns.to_p 'assignment').then (assignment) =>
      @assignment = assignment
      @phase      = phase
      @set 'phase_states', @pmap.get_all(ownerable, assignment)
      @set 'selected',     @pmap.get_selected(ownerable, phase)

  get_ownerable: ->
    ownerable = @pm.get_active_addon_ownerable()
    return ownerable if ember.isPresent(ownerable)
    @pm.get_current_user()
