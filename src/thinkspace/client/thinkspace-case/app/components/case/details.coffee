import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend  
  # # Services
  phase_manager: ember.inject.service()

  # # Properties
  model:        null
  teams:        null
  team_set:     null
  phase_states: null

  # # Computed Properties
  is_locked: ember.computed 'phase_states.@each.current_state', -> 
    !@get('phase_states').mapBy('is_locked').contains(false)

  is_completed: ember.computed 'phase_states.@each.current_state', ->
    !@get('phase_states').mapBy('is_completed').contains(false)

  is_read_only: ember.computed 'phase_states.@each.current_state', ->
    !@get('phase_states').mapBy('is_read_only').contains(false)

  is_in_progress: ember.computed 'phase_states.@each.current_state', ->
    states = []
    @get('phase_states').forEach (phase_state) =>
      has_valid = !phase_state.get('is_past_due') and phase_state.get('is_unlocked')
      states.pushObject(has_valid)
    states.contains(true)
    
  is_waiting: ember.computed 'phase_states.@each.current_state', ->
    phase_states  = @get('phase_states')
    has_completed = phase_states.mapBy('is_completed').contains(true)
    has_past_due  = phase_states.mapBy('is_past_due').contains(true)
    phase_states.mapBy('is_locked').contains(true) and (has_completed or has_past_due)

  next_due: ember.computed 'phase_states.@each.due_at', ->
    @get('phase_states').sortBy('due_at').get('firstObject')