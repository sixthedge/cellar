import ember from 'ember'

export default ember.Mixin.create

  # ownerable_map:
  #  ownerable:
  #    assignment:
  #      'has_phase_states': [true|false] #=> if have assignment's ownerable phase states
  #      'phases': phases in position order
  #      'phase_states': [[],[]] #=> array of arrays (array of each phase's phase states)
  #      'global': phase state
  #    phase:
  #      'selected': phase_state
  #      'phase_states': [] #=> array (same as in assignment phase states)

  reset_map: (ownerable, assignment) ->
    @error 'Reset map param ownerable is blank.' if ember.isBlank(ownerable)
    @error 'Reset map param assignment is blank.' if ember.isBlank(assignment)
    @set_has_phase_states(ownerable, assignment, false)
    @set_map(ownerable, assignment)

  set_map: (ownerable, assignment) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @error 'Set map param ownerable is blank.' if ember.isBlank(ownerable)
      @error 'Set map param assignment is blank.' if ember.isBlank(assignment)
      return resolve() if @has_phase_states(ownerable, assignment)
      return resolve() if !@pm.has_addon_ownerable() and @has_phase_states(@pm.get_current_user(), assignment)
      query =
        model:  assignment
        id:     assignment.get('id')
        action: 'phase_states'
        data:   {}
      @totem_scope.add_ownerable_to_query(query.data)
      @ajax.object(query).then (payload) =>
        @set_phase_map(ownerable, assignment, payload).then =>
          @set_has_phase_states(ownerable, assignment, true)
          resolve()

  set_phase_map: (ownerable, assignment, payload) ->
    new ember.RSVP.Promise (resolve, reject) =>
      assignment_phase_states = @tc.push_payload_and_return_records_for_type(payload, @ns.to_p('phase_state'))
      assignment.get(@ns.to_p 'phases').then =>
        phases = assignment.get('phases') # get in sorted order
        @set_phases(ownerable, assignment, phases)
        all_phase_states = []
        phases.forEach (phase) =>
          phase_states = @filter_phase_states_for_phase(phase, assignment_phase_states)
          phase_states = [@get_mock_phase_state(@pm.get_current_user(), phase)] if ember.isBlank(phase_states)
          @set_phase_states(ownerable, phase, phase_states)
          @set_selected(ownerable, phase, phase_states.get('firstObject'))
          all_phase_states.push(phase_states)
        @set_all(ownerable, assignment, all_phase_states)
        resolve()

  new_map: -> ember.Map.create()
  get_map: -> @ownerable_map ?= @new_map()

  get_omap: (ownerable) ->
    @error 'Ownerable map param ownerable is blank.' if ember.isBlank(ownerable)
    map  = @get_map()
    omap = map.get(ownerable)
    return omap if omap
    map.set ownerable, @new_map()
    map.get(ownerable)

  get_amap: (ownerable, assignment) ->
    @error 'Ownerable assignment map param ownerable is blank.', phase if ember.isBlank(ownerable)
    @error 'Ownerable assignment map param assignment is blank.', ownerable if ember.isBlank(assignment)
    omap = @get_omap(ownerable)
    amap = omap.get(assignment)
    return amap if amap
    omap.set assignment, @new_map()
    omap.get(assignment)

  get_pmap: (ownerable, phase) ->
    @error 'Ownerable phase map param ownerable is blank.', phase if ember.isBlank(ownerable)
    @error 'Ownerable phase map param phase is blank.', ownerable if ember.isBlank(ownerable)
    omap = @get_omap(ownerable)
    pmap = omap.get(phase)
    return pmap if pmap
    omap.set phase, @new_map()
    omap.get(phase)
