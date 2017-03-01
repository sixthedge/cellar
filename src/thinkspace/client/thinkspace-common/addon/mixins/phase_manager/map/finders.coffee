import ember from 'ember'

export default ember.Mixin.create

  find_phase_state_by_query_id: (ownerable, phase, query_id) ->
    return null if ember.isBlank(query_id) or query_id == 'none'
    phase_states = @get_phase_states(ownerable, phase)
    phase_states.findBy 'id', query_id + ''

  find_phase_state: (ownerable, phase, phase_state) ->
    return null if ember.isBlank(phase_state)
    phase_states = @get_phase_states(ownerable, phase)
    id           = phase_state.get('ownerable_id')
    type         = phase_state.get('ownerable_type')
    phase_states.find (state) => id == state.get('ownerable_id') and type == state.get('ownerable_type')

  find_next_phase_in_state: (phase, state='unlocked') ->
    @error 'Next phase in state param phase is blank.' if ember.isBlank(phase)
    new ember.RSVP.Promise (resolve, reject) =>
      phase.get(@ns.to_p 'assignment').then (assignment) =>
        return resolve(null) if ember.isBlank(assignment)
        @find_next_assignment_phase_in_state(assignment, state, phase).then (next_phase) =>
          resolve(next_phase)

  find_next_assignment_phase_in_state: (assignment, state='unlocked', phase=null) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @error 'Next phase in state param state is blank.' if ember.isBlank(state)
      @error 'Next phase in state param assignment is blank.' if ember.isBlank(assignment)
      ownerable = @pm.get_current_user()
      @error 'Next phase in state ownerable is blank.' if ember.isBlank(ownerable)
      phase_states = @get_all(ownerable, assignment)
      return resolve(null) if ember.isBlank(phase_states)
      if ember.isPresent(phase)
        index = @get_phases(ownerable, assignment).indexOf(phase)
        return resolve(null) unless index?
        phase_states = phase_states.slice(index + 1)
      return resolve(null) if ember.isBlank(phase_states)
      phase_state = @find_phase_state_in_state(phase_states, state)
      return resolve(null) if ember.isBlank(phase_state)
      phase_state.get(@ns.to_p 'phase').then (next_phase) =>
        return resolve(null) if ember.isBlank(next_phase)
        @set_selected(ownerable, next_phase, phase_state)
        resolve(next_phase)

  find_phase_state_in_state: (phase_states, state) ->
    find_state = if @util.starts_with('is_') then state else "is_#{state}"
    for ps_array in phase_states
      ps = ps_array.findBy(find_state)
      return ps if ember.isPresent(ps)
    null
