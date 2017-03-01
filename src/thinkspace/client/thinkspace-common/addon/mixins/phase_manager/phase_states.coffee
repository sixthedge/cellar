import ember from 'ember'

export default ember.Mixin.create

  # Phase state priority:
  #  1. phase-state-id e.g. from params query_id (null if id not found)
  #  2. selected-phase-state for ownerable and phase
  #  3. global-selected-phase-state if valid for the phase
  #  4. phase state that matches the global-selected-phase-state's ownerable
  #  5. null
  get_phase_state_for_phase: (phase, id) ->
    new ember.RSVP.Promise (resolve, reject) =>
      ownerable = @get_active_ownerable()
      selected  = @pmap.find_phase_state_by_query_id(ownerable, phase, id)
      return resolve(selected) if ember.isPresent(selected)
      selected = @pmap.get_selected(ownerable, phase)
      return resolve(selected) if ember.isPresent(selected)
      assignment      = @get_assignment()
      global_selected = @pmap.get_global(ownerable, assignment)
      return resolve(null) if ember.isBlank(global_selected)
      phase_states = @pmap.get_phase_states(ownerable, phase)
      return resolve(global_selected) if phase_states.includes(global_selected)
      phase_state = @pmap.find_phase_state(ownerable, phase, global_selected)
      resolve(phase_state)

  # Sets all of the ownerable phase states for each phase in the map.
  set_all_phase_states: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @validate_and_set_addon_ownerable().then =>
        assignment = @get_assignment()
        ownerable  = @get_ownerable()
        @pmap.set_map(ownerable, assignment).then => resolve()
